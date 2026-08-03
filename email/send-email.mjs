#!/usr/bin/env node

import { createHash } from "node:crypto";
import { appendFile, mkdir, readFile } from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";
import {
  buildSendGridPayload,
  sendWithSendGrid,
  validateMessage,
} from "./lib/sendgrid.mjs";

const EMAIL_DIR = path.dirname(fileURLToPath(import.meta.url));

function usage() {
  console.log(`Usage:
  node email/send-email.mjs --message <file.json>
  node email/send-email.mjs --message <file.json> --send --confirm <recipient@example.com>

Without --send, the command validates the message and prints a dry-run summary.`);
}

function parseArgs(argv) {
  const result = { send: false };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--send") result.send = true;
    else if (arg === "--message") result.messagePath = argv[++index];
    else if (arg === "--confirm") result.confirm = argv[++index];
    else if (arg === "--help" || arg === "-h") result.help = true;
    else throw new Error(`unknown argument: ${arg}`);
  }
  return result;
}

function recipientHash(email) {
  return createHash("sha256").update(email.trim().toLowerCase()).digest("hex");
}

async function loadMessage(messagePath) {
  if (!messagePath) throw new Error("--message is required");
  const raw = await readFile(path.resolve(messagePath), "utf8");
  return JSON.parse(raw);
}

async function writeAuditLog(message, result) {
  const logDir = path.join(EMAIL_DIR, ".local");
  const logPath = path.join(logDir, "sent-log.jsonl");
  await mkdir(logDir, { recursive: true });
  await appendFile(
    logPath,
    `${JSON.stringify({
      acceptedAt: new Date().toISOString(),
      sendGridStatus: result.status,
      sendGridMessageId: result.messageId,
      recipientHash: recipientHash(message.to.email),
      campaignId: message.metadata.campaignId,
      companySlug: message.metadata.companySlug,
      suppressionCheckedAt: message.metadata.suppressionCheckedAt,
    })}\n`,
    "utf8",
  );
  return logPath;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    usage();
    return;
  }

  const message = await loadMessage(args.messagePath);
  validateMessage(message);
  const payload = buildSendGridPayload(message);

  if (!args.send) {
    console.log("DRY RUN: no email was sent");
    console.log(
      JSON.stringify(
        {
          to: payload.personalizations[0].to,
          from: payload.from,
          subject: payload.subject,
          campaignId: message.metadata.campaignId,
          companySlug: message.metadata.companySlug,
          reviewApproved: message.metadata.reviewApproved,
          suppressionCheckedAt: message.metadata.suppressionCheckedAt,
          hasHtml: payload.content.some((item) => item.type === "text/html"),
          unsubscribeGroupConfigured: Boolean(payload.asm),
        },
        null,
        2,
      ),
    );
    return;
  }

  const recipient = message.to.email.trim().toLowerCase();
  if (!args.confirm || args.confirm.trim().toLowerCase() !== recipient) {
    throw new Error("--confirm must exactly match the recipient email address");
  }
  if (recipient.endsWith(".invalid")) {
    throw new Error("example .invalid recipients cannot be sent");
  }

  const result = await sendWithSendGrid(payload);
  const logPath = await writeAuditLog(message, result);
  console.log(`Accepted by SendGrid (${result.status}).`);
  console.log(`Local audit log: ${logPath}`);
}

main().catch((error) => {
  console.error(`ERROR: ${error.message}`);
  process.exitCode = 1;
});
