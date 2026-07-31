#!/usr/bin/env bash
set -euo pipefail

remote_url="https://github.com/QuickWorkInc/adr-seminar-bdr.git"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "not inside a git repository" >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$remote_url"
else
  git remote set-url origin "$remote_url"
fi

branch="$(git branch --show-current)"
if [[ "$branch" != "main" ]]; then
  echo "sync requires main branch; current branch: ${branch:-detached}" >&2
  exit 1
fi

bash scripts/validate-repo.sh
git push -u origin HEAD:main
