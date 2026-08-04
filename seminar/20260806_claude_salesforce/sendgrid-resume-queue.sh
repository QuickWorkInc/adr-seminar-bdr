#!/bin/zsh
set -euo pipefail

script_dir="${0:A:h}"
batch_file="${1:-$script_dir/bulk-email-batch-015.tsv}"
poll_seconds="${POLL_SECONDS:-60}"
log_file="$script_dir/sendgrid-resume-monitor.log"

[[ -f "$batch_file" ]] || { print -u2 'error: batch file not found'; exit 2; }
[[ "$poll_seconds" == <-> ]] || { print -u2 'error: POLL_SECONDS must be numeric'; exit 2; }

while true; do
  remaining="$(awk -F '\t' '
    NR == FNR { if (NR > 1) sent[tolower($2)] = 1; next }
    FNR > 1 && !sent[tolower($3)] { count++ }
    END { print count + 0 }
  ' "$script_dir/sent-email-ledger.tsv" "$batch_file")"

  if (( remaining == 0 )); then
    printf '%s\tcomplete\tremaining=0\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$log_file"
    exit 0
  fi

  credits_json="$($script_dir/sendgrid-api.sh /v3/user/credits)"
  credits="$(print -r -- "$credits_json" | jq -r '.remain // 0')"
  printf '%s\tpoll\tcredits=%s\tremaining=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$credits" "$remaining" >> "$log_file"

  if (( credits > 0 )); then
    "$script_dir/sendgrid-bulk-send.sh" "$batch_file" --live >> "$log_file" 2>&1 || true
  fi

  sleep "$poll_seconds"
done
