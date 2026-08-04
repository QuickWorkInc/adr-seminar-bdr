#!/usr/bin/env bash
set -euo pipefail

hook_dir=".githooks"
mkdir -p "$hook_dir"

hook_path="$hook_dir/post-commit"

chmod +x "$hook_dir/pre-commit"
chmod +x "$hook_path"
chmod +x scripts/notify-slack.sh
git config core.hooksPath "$hook_dir"
echo "installed post-commit hook: $hook_path"
