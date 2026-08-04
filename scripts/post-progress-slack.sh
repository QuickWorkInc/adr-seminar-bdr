#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f "$1" ]]; then
  echo "usage: $0 MESSAGE_FILE" >&2
  exit 2
fi

webhook_url="$(git config --local --get adr-seminar-bdr.slack-webhook-url 2>/dev/null || true)"
if [[ -z "$webhook_url" ]]; then
  echo "Slack webhook is not configured." >&2
  exit 1
fi

payload_file="$(mktemp)"
response_file="$(mktemp)"
trap 'rm -f "$payload_file" "$response_file"' EXIT

jq -Rs '{text: .}' < "$1" > "$payload_file"
http_code="$(curl --silent --show-error --max-time 30 \
  --output "$response_file" --write-out '%{http_code}' \
  --request POST \
  --header 'Content-Type: application/json' \
  --data-binary "@$payload_file" \
  "$webhook_url")"

if [[ "$http_code" != 200 || "$(cat "$response_file")" != "ok" ]]; then
  echo "Slack webhook failed with HTTP $http_code" >&2
  exit 1
fi

echo "Slack message sent"
