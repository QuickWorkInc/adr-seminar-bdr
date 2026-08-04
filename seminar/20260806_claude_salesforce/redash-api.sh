#!/bin/zsh
set -euo pipefail

if (( $# != 1 )); then
  print -u2 'usage: redash-api.sh /api/path'
  exit 2
fi

api_path="$1"
if [[ "$api_path" != /api/* ]]; then
  print -u2 'error: path must start with /api/'
  exit 2
fi

clipboard_value="$(pbpaste)"
if [[ -z "$clipboard_value" ]]; then
  print -u2 'error: clipboard does not contain an API key'
  exit 2
fi

if [[ "$clipboard_value" == *"="* ]]; then
  redash_key="${clipboard_value#*=}"
elif [[ "$clipboard_value" == *":"* ]]; then
  redash_key="${clipboard_value#*:}"
else
  redash_key="$clipboard_value"
fi

redash_key="${redash_key//$'\r'/}"
redash_key="${redash_key//$'\n'/}"
redash_key="${redash_key//[[:space:]]/}"
redash_key="${redash_key#\"}"
redash_key="${redash_key%\"}"
redash_key="${redash_key#\'}"
redash_key="${redash_key%\'}"
if [[ -z "$redash_key" || "$redash_key" == *[[:space:]]* ]]; then
  print -u2 'error: clipboard API key format is invalid'
  exit 2
fi

curl --silent --show-error --fail --max-time 60 \
  --header "Authorization: Key $redash_key" \
  "https://redash.office.salesnow.jp${api_path}"
