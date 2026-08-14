#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { chromium } from "playwright-core";

const args = process.argv.slice(2);
const option = (name, fallback = undefined) => {
  const index = args.indexOf(name);
  return index === -1 ? fallback : args[index + 1];
};
const queuePath = option("--queue");
const ledgerPath = option("--ledger");
const max = Number(option("--max", "1"));
const submit = args.includes("--submit");
const endpoint = option("--endpoint", "http://127.0.0.1:9222");

if (!queuePath || !ledgerPath) {
  console.error("usage: node form-runner.mjs --queue <queue.jsonl> --ledger <ledger.jsonl> [--max N] [--submit]");
  process.exit(2);
}
if (!Number.isInteger(max) || max < 1) {
  console.error("error: --max must be a positive integer");
  process.exit(2);
}

const now = () => new Date().toISOString();
const appendLedger = (entry) => fs.appendFileSync(ledgerPath, `${JSON.stringify({ at: now(), ...entry })}\n`);
const readJsonl = (file) => fs.readFileSync(file, "utf8").split("\n").filter(Boolean).map((line) => JSON.parse(line));
const ensureParent = (file) => fs.mkdirSync(path.dirname(path.resolve(file)), { recursive: true });

ensureParent(ledgerPath);
const queue = readJsonl(queuePath);
const attempted = fs.existsSync(ledgerPath)
  ? new Set(readJsonl(ledgerPath).filter((entry) => ["sent", "hold_recaptcha", "hold_timeout", "hold_unconfirmed", "skipped"].includes(entry.status)).map((entry) => entry.id))
  : new Set();
const candidates = queue.filter((entry) => entry.status === "approved" && !attempted.has(entry.id)).slice(0, max);

if (candidates.length === 0) {
  console.log("No approved, unprocessed queue entries.");
  process.exit(0);
}

let browser;
try {
  browser = await chromium.connectOverCDP(endpoint, { timeout: 15_000 });
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  for (const entry of candidates) {
    appendLedger({ id: entry.id, company_name: entry.company_name, url: entry.url, status: "hold_timeout", note: `Chrome connection unavailable: ${message}` });
  }
  console.error("Chrome connection unavailable. Entries were moved to hold_timeout without a submission attempt.");
  process.exit(1);
}

const recaptchaPresent = async (page) => {
  const selectors = [
    'iframe[src*="recaptcha"]',
    'textarea[name="g-recaptcha-response"]',
    '.g-recaptcha',
    '[data-sitekey]'
  ];
  return Boolean(await page.locator(selectors.join(",")).count());
};

const fillField = async (page, field) => {
  const selector = field.selector;
  const locator = page.locator(selector).first();
  if (await locator.count() === 0) throw new Error(`field_not_found:${selector}`);
  if (field.kind === "check") {
    if (!(await locator.isChecked())) await locator.check({ timeout: 5_000 });
  } else if (field.kind === "select") {
    await locator.selectOption({ label: field.value }).catch(async () => locator.selectOption(field.value));
  } else {
    await locator.fill(field.value, { timeout: 5_000 });
  }
};

for (const entry of candidates) {
  let page;
  try {
    const context = browser.contexts()[0] ?? await browser.newContext();
    page = await context.newPage();
    await page.goto(entry.url, { waitUntil: "domcontentloaded", timeout: 30_000 });
    if (await recaptchaPresent(page)) {
      appendLedger({ id: entry.id, company_name: entry.company_name, url: entry.url, status: "hold_recaptcha", note: "reCAPTCHA detected; no submission attempted" });
      console.log(`HOLD reCAPTCHA: ${entry.company_name}`);
      await page.close();
      continue;
    }
    for (const field of entry.fields ?? []) await fillField(page, field);
    if (!submit) {
      appendLedger({ id: entry.id, company_name: entry.company_name, url: entry.url, status: "ready", note: "fields filled in dry-run; use --submit only after review" });
      console.log(`READY: ${entry.company_name}`);
      await page.close();
      continue;
    }
    if (!entry.submit_selector) throw new Error("missing_submit_selector");
    await page.locator(entry.submit_selector).first().click({ timeout: 10_000 });
    await page.waitForTimeout(1_000);
    if (await recaptchaPresent(page)) {
      appendLedger({ id: entry.id, company_name: entry.company_name, url: entry.url, status: "hold_recaptcha", note: "reCAPTCHA appeared after form fill; no submission confirmed" });
      console.log(`HOLD reCAPTCHA: ${entry.company_name}`);
    } else if (entry.success_selector && await page.locator(entry.success_selector).first().isVisible({ timeout: 5_000 }).catch(() => false)) {
      appendLedger({ id: entry.id, company_name: entry.company_name, url: entry.url, status: "sent", note: "completion selector verified" });
      console.log(`SENT: ${entry.company_name}`);
    } else {
      appendLedger({ id: entry.id, company_name: entry.company_name, url: entry.url, status: "hold_unconfirmed", note: "submission was clicked but completion could not be verified" });
      console.log(`HOLD UNCONFIRMED: ${entry.company_name}`);
    }
    await page.close();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    const status = /Timeout|timeout|ECONNREFUSED|Target page, context or browser has been closed/.test(message) ? "hold_timeout" : "skipped";
    appendLedger({ id: entry.id, company_name: entry.company_name, url: entry.url, status, note: message });
    console.log(`${status.toUpperCase()}: ${entry.company_name} (${message})`);
    if (page && !page.isClosed()) await page.close().catch(() => {});
  }
}

await browser.close();
