#!/usr/bin/env bash
set -euo pipefail

remote_url="https://github.com/QuickWorkInc/adr-seminar-bdr.git"

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "origin is not configured" >&2
  exit 1
fi

git remote set-url origin "$remote_url"
git fetch origin main

local_head="$(git rev-parse main)"
remote_head="$(git rev-parse origin/main)"

if [[ "$local_head" != "$remote_head" ]]; then
  echo "not synced: local main=$local_head origin/main=$remote_head" >&2
  exit 1
fi

echo "OK: local main is synced with origin/main."
