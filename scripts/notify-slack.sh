#!/usr/bin/env bash
set -euo pipefail

load_env_file() {
  local env_file=".env.local"
  if [[ -f "$env_file" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
  fi
}

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

get_webhook_url() {
  if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
    echo "$SLACK_WEBHOOK_URL"
    return
  fi

  git config --local --get adr-seminar-bdr.slack-webhook-url 2>/dev/null || true
}

get_config_value() {
  local env_name="$1"
  local git_key="$2"
  local env_value="${!env_name:-}"

  if [[ -n "$env_value" ]]; then
    echo "$env_value"
    return
  fi

  git config --local --get "$git_key" 2>/dev/null || true
}

build_parent_message() {
  local commit_sha="$1"
  local short_sha
  local subject
  local changed_count

  short_sha="$(git rev-parse --short "$commit_sha")"
  subject="$(git log -1 --format=%s "$commit_sha")"
  changed_count="$(git diff-tree --no-commit-id --name-only -r "$commit_sha" | wc -l | tr -d ' ')"

  echo "*ADR Seminar BDR更新* — \`$short_sha\` $subject"
  echo "変更ファイル${changed_count}件。詳細はスレッドに記載します。"
}

build_detail_message() {
  local commit_sha="$1"
  local short_sha
  local subject
  local author
  local changed_files
  local stats
  local full_diff
  local delivery_log_sheet_url

  delivery_log_sheet_url="https://docs.google.com/spreadsheets/d/1oQZMXewYMeC1a3075JX7IRx7fLwHSLoiithL1yj-KG8/edit?gid=0#gid=0"
  short_sha="$(git rev-parse --short "$commit_sha")"
  subject="$(git log -1 --format=%s "$commit_sha")"
  author="$(git log -1 --format='%an <%ae>' "$commit_sha")"
  changed_files="$(git diff-tree --no-commit-id --name-status -r "$commit_sha" | sed -n '1,80p')"
  stats="$(git show --stat --oneline --no-renames "$commit_sha" | sed -n '1,80p')"
  full_diff="$(git show --no-ext-diff --format= --find-renames --find-copies "$commit_sha")"

  {
    echo "*変更概要*"
    echo "- Commit: \`$short_sha\` $subject"
    echo "- Author: $author"
    echo "- 配信ログ正本: $delivery_log_sheet_url"
    echo
    echo "*変更ファイル*"
    echo '```'
    echo "${changed_files:-なし}"
    echo '```'
    echo
    echo "*変更サマリ*"
    echo '```'
    echo "${stats:-なし}"
    echo '```'
    echo
    echo "*改変詳細(diff全文)*"
    echo '```'
    echo "${full_diff:-差分なし}"
    echo '```'
    echo
    echo "*鉄の掟*"
    echo "配信ログは1配信につき1行で上記スプレッドシートへ集約する。対象セミナー、配信セグメント、配信件数、配信手法、ベースメッセージを必ず記録する。"
  }
}

send_webhook_message() {
  local webhook_url="$1"
  local message="$2"
  local escaped_message

  escaped_message="$(printf '%s' "$message" | json_escape)"
  curl -fsS -X POST -H 'Content-type: application/json' \
    --data "{\"text\":$escaped_message}" \
    "$webhook_url" >/dev/null
}

post_slack_api_message() {
  local token="$1"
  local channel="$2"
  local text="$3"
  local thread_ts="${4:-}"
  local escaped_text
  local escaped_thread_ts
  local payload

  escaped_text="$(printf '%s' "$text" | json_escape)"
  payload="{\"channel\":\"$channel\",\"text\":$escaped_text}"
  if [[ -n "$thread_ts" ]]; then
    escaped_thread_ts="$(printf '%s' "$thread_ts" | json_escape)"
    payload="{\"channel\":\"$channel\",\"text\":$escaped_text,\"thread_ts\":$escaped_thread_ts}"
  fi

  curl -fsS -X POST https://slack.com/api/chat.postMessage \
    -H "Authorization: Bearer $token" \
    -H 'Content-type: application/json; charset=utf-8' \
    --data "$payload"
}

extract_slack_ts() {
  python3 -c 'import json,sys; data=json.load(sys.stdin); print(data.get("ts","")); sys.exit(0 if data.get("ok") else 1)'
}

split_and_post_thread() {
  local token="$1"
  local channel="$2"
  local thread_ts="$3"
  local detail="$4"

  DETAIL_TEXT="$detail" python3 - <<'PY' | while IFS= read -r chunk; do
import os

text = os.environ["DETAIL_TEXT"]
limit = 32000
for start in range(0, len(text), limit):
    chunk = text[start:start + limit]
    print(chunk.replace("\n", "\\n"))
PY
    chunk="${chunk//\\n/$'\n'}"
    post_slack_api_message "$token" "$channel" "$chunk" "$thread_ts" >/dev/null
  done
}

main() {
  local commit_sha="${1:-HEAD}"
  local webhook_url
  local bot_token
  local channel_id
  local parent_message
  local detail_message
  local response
  local thread_ts

  load_env_file
  webhook_url="$(get_webhook_url)"
  bot_token="$(get_config_value SLACK_BOT_TOKEN adr-seminar-bdr.slack-bot-token)"
  channel_id="$(get_config_value SLACK_CHANNEL_ID adr-seminar-bdr.slack-channel-id)"

  parent_message="$(build_parent_message "$commit_sha")"
  detail_message="$(build_detail_message "$commit_sha")"

  if [[ -n "$bot_token" && -n "$channel_id" ]]; then
    response="$(post_slack_api_message "$bot_token" "$channel_id" "$parent_message")"
    thread_ts="$(printf '%s' "$response" | extract_slack_ts)"
    split_and_post_thread "$bot_token" "$channel_id" "$thread_ts" "$detail_message"
    return
  fi

  if [[ -z "$webhook_url" ]]; then
    echo "Slack notification is not configured. Set SLACK_BOT_TOKEN + SLACK_CHANNEL_ID, or SLACK_WEBHOOK_URL." >&2
    exit 1
  fi

  send_webhook_message "$webhook_url" "$parent_message"
}

main "$@"
