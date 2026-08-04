#!/usr/bin/env bash
set -euo pipefail

required_paths=(
  ".githooks/pre-commit"
  ".githooks/post-commit"
  "seminar/README.md"
  "seminar/delivery-log-sheet.md"
  "seminar/salesnow-data-redash.md"
  "email/README.md"
  "contact/README.md"
  "contact/form-profile.md"
  "sns/README.md"
  "docs/CHANGELOG.md"
  "scripts/check-sync-status.sh"
  "scripts/notify-slack.sh"
)

required_terms=(
  "パーソナライズ"
  "セミナー内容"
  "企業"
  "経営ベネフィット"
  "P/Lインパクト"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "missing required file: $path" >&2
    exit 1
  fi
done

for path in README.md email/README.md contact/README.md sns/README.md seminar/README.md; do
  for term in "${required_terms[@]}"; do
    if ! grep -q "$term" "$path"; then
      echo "missing required term '$term' in $path" >&2
      exit 1
    fi
  done
done

while IFS= read -r dir; do
  dir_name="$(basename "$dir")"
  if [[ "$dir_name" =~ ^[0-9]{8}_.+ && "$dir" != ./seminar/* ]]; then
    echo "seminar workspace directory must be under ./seminar only: $dir" >&2
    exit 1
  fi
done < <(find . -path './.git' -prune -o -type d -print)

validate_campaign() {
  local campaign_dir="$1"
  local brief_path="$campaign_dir/brief.md"
  local research_dir="$campaign_dir/company-research"
  local drafts_dir="$campaign_dir/drafts"
  local reviews_dir="$campaign_dir/reviews"

  if [[ ! -f "$brief_path" ]]; then
    echo "missing campaign brief: $brief_path" >&2
    exit 1
  fi

  if grep -Eq "内容確認待ち|ここに|未確定事項" "$brief_path"; then
    echo "campaign brief is not ready: $brief_path" >&2
    exit 1
  fi

  shopt -s nullglob
  local research_files=("$research_dir"/*.md)
  local real_research_files=()

  for research_file in "${research_files[@]}"; do
    if [[ "$(basename "$research_file")" != "_template.md" && "$(basename "$research_file")" != "README.md" ]]; then
      real_research_files+=("$research_file")
    fi
  done

  if [[ "${#real_research_files[@]}" -eq 0 ]]; then
    echo "campaign requires at least one company research file" >&2
    exit 1
  fi

  local campaign_terms=(
    "企業名:"
    "公式サイトURL:"
    "セミナー内容との接続点:"
    "経営ベネフィット:"
    "P/Lインパクト仮説:"
  )

  for research_file in "${real_research_files[@]}"; do
    local slug
    slug="$(basename "$research_file" .md)"

    for term in "${campaign_terms[@]}"; do
      if ! grep -q "$term" "$research_file"; then
        echo "missing required campaign term '$term' in $research_file" >&2
        exit 1
      fi
    done

    local found_channel_draft=0
    for channel in email contact sns; do
      local draft_file="$drafts_dir/$slug-$channel.md"
      if [[ ! -f "$draft_file" ]]; then
        continue
      fi
      found_channel_draft=1
      for term in "企業固有の文脈:" "セミナー内容との接続:" "経営ベネフィット:" "P/Lインパクト:"; do
        if ! grep -q "$term" "$draft_file"; then
          echo "missing required draft term '$term' in $draft_file" >&2
          exit 1
        fi
      done
    done
    if [[ "$found_channel_draft" -eq 0 ]]; then
      echo "campaign requires at least one channel draft for: $slug" >&2
      exit 1
    fi

    local review_file="$reviews_dir/$slug.md"
    if [[ ! -f "$review_file" ]]; then
      echo "missing review: $review_file" >&2
      exit 1
    fi
    if ! grep -q "decision: approved" "$review_file"; then
      echo "review is not approved: $review_file" >&2
      exit 1
    fi
  done
}

if [[ "${1:-}" == "--campaign" ]]; then
  if [[ -z "${2:-}" ]]; then
    echo "usage: $0 --campaign seminar/<campaign-id>" >&2
    exit 1
  fi
  validate_campaign "$2"
fi

echo "OK: ADR seminar BDR repository rules are present."
