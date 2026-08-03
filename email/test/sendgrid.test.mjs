import assert from "node:assert/strict";
import test from "node:test";
import {
  buildSendGridPayload,
  sendWithSendGrid,
  validateMessage,
} from "../lib/sendgrid.mjs";

function validMessage() {
  return {
    to: { email: "recipient@example.com", name: "Recipient" },
    subject: "Personalized seminar invitation",
    text: "Personalized body with business impact.",
    metadata: {
      campaignId: "20260804_claude_salesforce",
      companySlug: "example",
      recipientRole: "Director",
      personalizationEvidence: "Official company announcement about its sales strategy.",
      businessImpact: "Reduce sales preparation time and improve pipeline creation.",
      sourceReferences: ["https://example.com/news"],
      reviewApproved: true,
      suppressionChecked: true,
      suppressionCheckedAt: "2026-08-03T00:00:00+09:00",
    },
  };
}

test("builds a SendGrid v3 payload without exposing compliance metadata", () => {
  const payload = buildSendGridPayload(validMessage(), {
    SENDGRID_FROM_EMAIL: "sender@example.com",
    SENDGRID_FROM_NAME: "SalesNow",
    SENDGRID_UNSUBSCRIBE_GROUP_ID: "123",
  });

  assert.deepEqual(payload.personalizations[0].to, [
    { email: "recipient@example.com", name: "Recipient" },
  ]);
  assert.equal(payload.from.email, "sender@example.com");
  assert.deepEqual(payload.asm, { group_id: 123 });
  assert.equal(payload.personalizations[0].custom_args.company_slug, "example");
  assert.equal(payload.content[0].type, "text/plain");
});

test("rejects messages without review approval", () => {
  const message = validMessage();
  message.metadata.reviewApproved = false;
  assert.throws(() => validateMessage(message), /reviewApproved must be true/);
});

test("rejects messages without a suppression check timestamp", () => {
  const message = validMessage();
  delete message.metadata.suppressionCheckedAt;
  assert.throws(() => validateMessage(message), /suppressionCheckedAt is required/);
});

test("sends to the SendGrid v3 endpoint and accepts only HTTP 202", async () => {
  let request;
  const result = await sendWithSendGrid(
    { subject: "test" },
    {
      apiKey: "test-key",
      fetchImpl: async (url, options) => {
        request = { url, options };
        return {
          status: 202,
          headers: new Headers({ "x-message-id": "message-123" }),
          text: async () => "",
        };
      },
    },
  );

  assert.equal(request.url, "https://api.sendgrid.com/v3/mail/send");
  assert.equal(request.options.headers.Authorization, "Bearer test-key");
  assert.deepEqual(result, { status: 202, messageId: "message-123" });
});

test("includes SendGrid error details when a request is rejected", async () => {
  await assert.rejects(
    sendWithSendGrid(
      { subject: "test" },
      {
        apiKey: "test-key",
        fetchImpl: async () => ({
          status: 400,
          headers: new Headers(),
          text: async () => '{"errors":[{"message":"invalid request"}]}',
        }),
      },
    ),
    /SendGrid rejected the request \(400\).*invalid request/,
  );
});
