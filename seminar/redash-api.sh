#!/bin/zsh
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
exec "$script_dir/20260806_claude_salesforce/redash-api.sh" "$@"
