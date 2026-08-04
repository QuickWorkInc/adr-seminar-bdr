#!/bin/zsh
set -euo pipefail

usage() {
  print -u2 'usage: sendgrid-send.sh PAYLOAD_JSON [--live]'
  exit 2
}

(( $# >= 1 && $# <= 2 )) || usage
payload_file="$1"
mode="${2:-}"
[[ -f "$payload_file" ]] || { print -u2 'error: payload file not found'; exit 2; }

jq -e '
  (.personalizations | type == "array" and length == 1) and
  (.personalizations[0].to | type == "array" and length == 1) and
  (.personalizations[0].to[0].email | type == "string" and length > 3) and
  (.from.email == "tomoya-takeuchi@salesnow.jp") and
  (.reply_to.email == "tomoya-takeuchi@salesnow.jp") and
  (.subject | type == "string" and length > 0) and
  (.content | type == "array" and length > 0)
' "$payload_file" >/dev/null || {
  print -u2 'error: payload validation failed'
  exit 1
}

recipient="$(jq -r '.personalizations[0].to[0].email' "$payload_file")"
subject="$(jq -r '.subject' "$payload_file")"

if [[ "$mode" != "--live" ]]; then
  jq '{mode:"dry-run",to:.personalizations[0].to[0].email,from:.from.email,reply_to:.reply_to.email,subject,content_types:[.content[].type]}' "$payload_file"
  exit 0
fi

stored_key="$(git config --local --get adr-seminar-bdr.sendgrid-api-key 2>/dev/null || true)"
if [[ -n "$stored_key" ]]; then
  sendgrid_key="$stored_key"
else
  clipboard_value="$(pbpaste)"
  if [[ "$clipboard_value" == *"="* ]]; then
    sendgrid_key="${clipboard_value#*=}"
  else
    sendgrid_key="$clipboard_value"
  fi
fi
sendgrid_key="${sendgrid_key//$'\r'/}"
sendgrid_key="${sendgrid_key//$'\n'/}"
sendgrid_key="${sendgrid_key//[[:space:]]/}"
sendgrid_key="${sendgrid_key#\"}"
sendgrid_key="${sendgrid_key%\"}"
sendgrid_key="${sendgrid_key#\'}"
sendgrid_key="${sendgrid_key%\'}"
[[ -n "$sendgrid_key" ]] || { print -u2 'error: SendGrid API key is not configured'; exit 2; }

response_headers="$(mktemp)"
response_body="$(mktemp)"
trap 'rm -f "$response_headers" "$response_body"' EXIT
http_code="$(curl --silent --show-error --max-time 60 \
  --dump-header "$response_headers" --output "$response_body" --write-out '%{http_code}' \
  --request POST \
  --header "Authorization: Bearer $sendgrid_key" \
  --header 'Content-Type: application/json' \
  --data-binary "@$payload_file" \
  'https://api.sendgrid.com/v3/mail/send')"

message_id="$(awk 'BEGIN{IGNORECASE=1} /^x-message-id:/ {gsub(/\r/,""); sub(/^[^:]+:[[:space:]]*/,""); print; exit}' "$response_headers")"
if [[ "$http_code" != 202 ]]; then
  print -u2 "error: SendGrid returned HTTP $http_code"
  jq '{errors:[.errors[]? | {message,field,help}]}' "$response_body" >&2 2>/dev/null || true
  exit 1
fi

jq -n --arg to "$recipient" --arg subject "$subject" --arg message_id "$message_id" \
  '{status:"accepted",to:$to,subject:$subject,message_id:$message_id}'
