#!/bin/zsh
set -euo pipefail

if (( $# < 1 || $# > 2 )); then
  print -u2 'usage: sendgrid-bulk-send.sh BATCH_TSV [--live]'
  exit 2
fi

batch_file="$1"
mode="${2:-}"
[[ -f "$batch_file" ]] || { print -u2 'error: batch file not found'; exit 2; }
[[ "$(head -n 1 "$batch_file")" == $'corporate_number\tcompany_name\temail\tindustry\temployees\tsubject\tcontext\tbenefit\tpl_impact\tsource_url' ]] || {
  print -u2 'error: invalid batch header'
  exit 1
}

stored_key="$(git config --local --get adr-seminar-bdr.sendgrid-api-key 2>/dev/null || true)"
[[ -n "$stored_key" ]] || { print -u2 'error: SendGrid API key is not configured'; exit 2; }

script_dir="${0:A:h}"
ledger_file="$script_dir/sent-email-ledger.tsv"
lock_dir="$script_dir/.sendgrid-bulk-send.lock"
if ! mkdir "$lock_dir" 2>/dev/null; then
  print -u2 'error: another SendGrid bulk process is already running for this campaign'
  exit 3
fi
trap 'rmdir "$lock_dir" 2>/dev/null || true' EXIT INT TERM

tail -n +2 "$batch_file" | while IFS=$'\t' read -r corporate_number company_name email industry employees subject context benefit pl_impact source_url; do
  [[ -n "$email" && -n "$company_name" && -n "$context" && -n "$benefit" && -n "$pl_impact" ]] || {
    jq -cn --arg company "$company_name" --arg email "$email" '{status:"skipped",company:$company,email:$email,reason:"missing_required_field"}'
    continue
  }

  if [[ -f "$ledger_file" ]] && awk -F $'\t' -v target="$email" 'NR > 1 && $2 == target { found=1 } END { exit !found }' "$ledger_file"; then
    jq -cn --arg company "$company_name" --arg email "$email" '{status:"skipped",company:$company,email:$email,reason:"already_sent"}'
    continue
  fi

  suppressed=false
  for endpoint in bounces blocks spam_reports; do
    http_code="$(curl --silent --output /dev/null --write-out '%{http_code}' --max-time 30 \
      --header "Authorization: Bearer $stored_key" \
      "https://api.sendgrid.com/v3/$endpoint/${email//@/%40}")"
    if [[ "$http_code" == 200 ]]; then
      suppressed=true
    elif [[ "$http_code" != 404 ]]; then
      jq -cn --arg company "$company_name" --arg email "$email" --arg endpoint "$endpoint" --arg code "$http_code" \
        '{status:"skipped",company:$company,email:$email,reason:("suppression_check_http_"+$code),endpoint:$endpoint}'
      suppressed=true
      break
    fi
  done
  if [[ "$suppressed" == true ]]; then
    jq -cn --arg company "$company_name" --arg email "$email" '{status:"skipped",company:$company,email:$email,reason:"suppressed"}'
    continue
  fi

  global_response="$(curl --silent --show-error --max-time 30 \
    --header "Authorization: Bearer $stored_key" \
    "https://api.sendgrid.com/v3/asm/suppressions/global/${email//@/%40}")"
  if [[ "$(print -r -- "$global_response" | jq -r '.suppressed // false')" == true ]]; then
    jq -cn --arg company "$company_name" --arg email "$email" '{status:"skipped",company:$company,email:$email,reason:"global_unsubscribe"}'
    continue
  fi

  body="ご担当者様

お世話になっております。株式会社SalesNowの竹内と申します。

貴社が${context}されている点を拝見し、営業企画・Salesforce運用に関わる方へご案内したくご連絡しました。

8月6日（木）13:00より、無料オンラインセミナー「Claude × Salesforce 活用大全──AI時代の営業生産性向上術」を開催します。

受注率分析、データの名寄せ、レポート作成、失注商談の掘り起こしなど、営業データを「見る・動かす・任せる」の3段階で整理した10の活用法と弊社の実装事例をご紹介します。

${benefit}。${pl_impact}にも応用いただける内容です。

▼無料・オンラインでのお申し込み
https://salesnow.jp/seminars/52/?a=sn_outmail

当日ご都合が合わない場合は、個別に30分ほどで同内容をご案内できます。
今後このようなご案内が不要な場合は、本メールに「配信停止」とご返信ください。

株式会社SalesNow
竹内智康
電話: 03-6844-1166
メール: tomoya-takeuchi@salesnow.jp"

  payload="$(jq -cn --arg email "$email" --arg company "$company_name" --arg subject "$subject" --arg body "$body" '{
    personalizations:[{to:[{email:$email,name:($company+" ご担当者様")}]}],
    from:{email:"tomoya-takeuchi@salesnow.jp",name:"株式会社SalesNow 竹内智康"},
    reply_to:{email:"tomoya-takeuchi@salesnow.jp",name:"竹内智康"},
    subject:$subject,
    content:[{type:"text/plain",value:$body}]
  }')"

  if [[ "$mode" != --live ]]; then
    jq -cn --arg company "$company_name" --arg email "$email" --arg subject "$subject" '{status:"dry-run",company:$company,email:$email,subject:$subject}'
    continue
  fi

  headers="$(mktemp)"
  response="$(mktemp)"
  http_code="$(curl --silent --show-error --max-time 60 --dump-header "$headers" --output "$response" --write-out '%{http_code}' \
    --request POST --header "Authorization: Bearer $stored_key" --header 'Content-Type: application/json' \
    --data-binary "$payload" 'https://api.sendgrid.com/v3/mail/send')"
  if [[ "$http_code" == 202 ]]; then
    message_id="$(awk 'BEGIN{IGNORECASE=1} /^x-message-id:/ {gsub(/\r/,""); sub(/^[^:]+:[[:space:]]*/,""); print; exit}' "$headers")"
    printf '%s\t%s\t%s\t%s\t%s\n' "$corporate_number" "$email" "$company_name" "${batch_file:t}" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$ledger_file"
    jq -cn --arg company "$company_name" --arg email "$email" --arg message_id "$message_id" '{status:"accepted",company:$company,email:$email,message_id:$message_id}'
  else
    error_message="$(jq -r '[.errors[]?.message] | join("; ")' "$response" 2>/dev/null || true)"
    jq -cn --arg company "$company_name" --arg email "$email" --arg code "$http_code" --arg error "$error_message" \
      '{status:"failed",company:$company,email:$email,http_code:$code,error:$error}'
  fi
done
