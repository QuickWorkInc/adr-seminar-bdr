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

build_commit_message() {
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
    echo "*ADR Seminar BDR 改変履歴通知*"
    echo "*Commit:* \`$short_sha\` $subject"
    echo "*Author:* $author"
    echo "*配信ログ正本:* $delivery_log_sheet_url"
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

send_slack_message() {
  local webhook_url="$1"
  local message="$2"
  local escaped_message

  escaped_message="$(printf '%s' "$message" | json_escape)"
  curl -fsS -X POST -H 'Content-type: application/json' \
    --data "{\"text\":$escaped_message}" \
    "$webhook_url" >/dev/null
}

main() {
  local commit_sha="${1:-HEAD}"
  local webhook_url
  local message

  load_env_file
  webhook_url="$(get_webhook_url)"

  if [[ -z "$webhook_url" ]]; then
    echo "Slack webhook is not configured. Set SLACK_WEBHOOK_URL or git config adr-seminar-bdr.slack-webhook-url." >&2
    exit 1
  fi

  message="$(build_commit_message "$commit_sha")"
  send_slack_message "$webhook_url" "$message"
}

main "$@"
