const SENDGRID_ENDPOINT = "https://api.sendgrid.com/v3/mail/send";

function requiredString(value, field) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(`${field} is required`);
  }
  return value.trim();
}

function validateEmail(value, field) {
  const email = requiredString(value, field).toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error(`${field} must be a valid email address`);
  }
  return email;
}

function optionalNamedAddress(email, name, field) {
  if (!email) return undefined;
  const address = { email: validateEmail(email, `${field}.email`) };
  if (name?.trim()) address.name = name.trim();
  return address;
}

export function validateMessage(message) {
  if (!message || typeof message !== "object" || Array.isArray(message)) {
    throw new Error("message must be a JSON object");
  }

  validateEmail(message.to?.email, "to.email");
  requiredString(message.subject, "subject");
  requiredString(message.text, "text");

  const metadata = message.metadata;
  if (!metadata || typeof metadata !== "object" || Array.isArray(metadata)) {
    throw new Error("metadata is required");
  }

  for (const field of [
    "campaignId",
    "companySlug",
    "recipientRole",
    "personalizationEvidence",
    "businessImpact",
  ]) {
    requiredString(metadata[field], `metadata.${field}`);
  }

  if (!Array.isArray(metadata.sourceReferences) || metadata.sourceReferences.length === 0) {
    throw new Error("metadata.sourceReferences must contain at least one source");
  }
  metadata.sourceReferences.forEach((source, index) =>
    requiredString(source, `metadata.sourceReferences[${index}]`),
  );

  if (metadata.reviewApproved !== true) {
    throw new Error("metadata.reviewApproved must be true");
  }
  if (metadata.suppressionChecked !== true) {
    throw new Error("metadata.suppressionChecked must be true");
  }

  const checkedAt = requiredString(
    metadata.suppressionCheckedAt,
    "metadata.suppressionCheckedAt",
  );
  if (Number.isNaN(Date.parse(checkedAt))) {
    throw new Error("metadata.suppressionCheckedAt must be an ISO 8601 date-time");
  }

  return message;
}

export function buildSendGridPayload(message, env = process.env) {
  validateMessage(message);

  const to = optionalNamedAddress(message.to.email, message.to.name, "to");
  const from = optionalNamedAddress(
    env.SENDGRID_FROM_EMAIL,
    env.SENDGRID_FROM_NAME,
    "from",
  );
  if (!from) throw new Error("SENDGRID_FROM_EMAIL is required");

  const payload = {
    personalizations: [
      {
        to: [to],
        custom_args: {
          campaign_id: message.metadata.campaignId,
          company_slug: message.metadata.companySlug,
        },
      },
    ],
    from,
    subject: message.subject.trim(),
    content: [{ type: "text/plain", value: message.text }],
    categories: ["adr-seminar-bdr"],
  };

  if (message.html?.trim()) {
    payload.content.push({ type: "text/html", value: message.html });
  }

  const replyTo = optionalNamedAddress(
    env.SENDGRID_REPLY_TO_EMAIL,
    env.SENDGRID_REPLY_TO_NAME,
    "reply_to",
  );
  if (replyTo) payload.reply_to = replyTo;

  if (env.SENDGRID_UNSUBSCRIBE_GROUP_ID) {
    const groupId = Number(env.SENDGRID_UNSUBSCRIBE_GROUP_ID);
    if (!Number.isSafeInteger(groupId) || groupId <= 0) {
      throw new Error("SENDGRID_UNSUBSCRIBE_GROUP_ID must be a positive integer");
    }
    payload.asm = { group_id: groupId };
  }

  return payload;
}

export async function sendWithSendGrid(
  payload,
  { apiKey = process.env.SENDGRID_API_KEY, fetchImpl = fetch } = {},
) {
  const key = requiredString(apiKey, "SENDGRID_API_KEY");
  const response = await fetchImpl(SENDGRID_ENDPOINT, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (response.status !== 202) {
    const body = await response.text();
    throw new Error(
      `SendGrid rejected the request (${response.status}): ${body || "no response body"}`,
    );
  }

  return {
    status: response.status,
    messageId: response.headers.get("x-message-id") || null,
  };
}
