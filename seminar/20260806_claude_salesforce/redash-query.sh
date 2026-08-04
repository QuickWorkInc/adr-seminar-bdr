#!/bin/zsh
set -euo pipefail

if (( $# < 1 || $# > 2 )); then
  print -u2 'usage: redash-query.sh SQL_FILE [DATA_SOURCE_ID]'
  exit 2
fi

sql_file="$1"
data_source_id="${2:-4}"
if [[ "$data_source_id" != <-> ]]; then
  print -u2 'error: data source id must be numeric'
  exit 2
fi
if [[ ! -f "$sql_file" ]]; then
  print -u2 'error: SQL file not found'
  exit 2
fi

clipboard_value="$(pbpaste)"
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
redash_key="${redash_key#Key}"
redash_key="${redash_key#key}"
redash_key="${redash_key#\"}"
redash_key="${redash_key%\"}"
redash_key="${redash_key#\'}"
redash_key="${redash_key%\'}"
if [[ -z "$redash_key" ]]; then
  print -u2 'error: clipboard does not contain an API key'
  exit 2
fi

payload_file="$(mktemp)"
response_file="$(mktemp)"
trap 'rm -f "$payload_file" "$response_file"' EXIT

jq -n --rawfile query "$sql_file" --argjson data_source_id "$data_source_id" \
  '{data_source_id: $data_source_id, query: $query, max_age: 0}' > "$payload_file"

curl --silent --show-error --fail --max-time 60 \
  --header "Authorization: Key $redash_key" \
  --header 'Content-Type: application/json' \
  --data-binary "@$payload_file" \
  'https://redash.office.salesnow.jp/api/query_results' > "$response_file"

query_result_id="$(jq -r '.query_result.id // empty' "$response_file")"
if [[ -n "$query_result_id" ]]; then
  cat "$response_file"
  exit 0
fi

job_id="$(jq -r '.job.id // empty' "$response_file")"
if [[ -z "$job_id" ]]; then
  jq '{error,job,query_result}' "$response_file" >&2
  exit 1
fi
print -u2 "redash_job_id=$job_id"

for attempt in {1..30}; do
  curl --silent --show-error --fail --max-time 30 \
    --header "Authorization: Key $redash_key" \
    "https://redash.office.salesnow.jp/api/jobs/$job_id" > "$response_file"
  job_status="$(jq -r '.job.status' "$response_file")"
  if [[ "$job_status" == 3 ]]; then
    query_result_id="$(jq -r '.job.query_result_id' "$response_file")"
    print -u2 "redash_query_result_id=$query_result_id"
    curl --silent --show-error --fail --max-time 60 \
      --header "Authorization: Key $redash_key" \
      "https://redash.office.salesnow.jp/api/query_results/$query_result_id"
    exit 0
  fi
  if [[ "$job_status" == 4 || "$job_status" == 5 ]]; then
    jq '{job:{status:.job.status,error:.job.error}}' "$response_file" >&2
    exit 1
  fi
  sleep 2
done

print -u2 'error: Redash query timed out'
exit 1
