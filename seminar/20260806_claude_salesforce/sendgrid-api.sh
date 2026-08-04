#!/bin/zsh
set -euo pipefail

if (( $# != 1 )); then
  print -u2 'usage: sendgrid-api.sh /v3/path'
  exit 2
fi

api_path="$1"
if [[ "$api_path" != /v3/* ]]; then
  print -u2 'error: path must start with /v3/'
  exit 2
fi

stored_key="$(git config --local --get adr-seminar-bdr.sendgrid-api-key 2>/dev/null || true)"
if [[ -n "$stored_key" ]]; then
  sendgrid_key="$stored_key"
else
  clipboard_value="$(pbpaste)"
  if [[ "$clipboard_value" == *"="* ]]; then
    sendgrid_key="${clipboard_value#*=}"
  elif [[ "$clipboard_value" == *":"* ]]; then
    sendgrid_key="${clipboard_value#*:}"
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
if [[ -z "$sendgrid_key" ]]; then
  print -u2 'error: SendGrid API key is not configured'
  exit 2
fi

curl --silent --show-error --fail --max-time 60 \
  --header "Authorization: Bearer $sendgrid_key" \
  "https://api.sendgrid.com${api_path}"
