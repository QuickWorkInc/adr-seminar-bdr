#!/bin/zsh
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"

if "$script_dir/redash-api.sh" /api/data_sources >/dev/null 2>&1 && "$script_dir/redash-api.sh" /api/current_user >/dev/null 2>&1; then
  print "Redash authentication: verified"
  exit 0
fi

print -u2 "Redash authentication: unavailable. Use the shared client from this repository; do not paste the API key into chat or project files."
exit 1
