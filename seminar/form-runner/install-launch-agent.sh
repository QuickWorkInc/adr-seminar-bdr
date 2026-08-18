#!/bin/zsh
set -euo pipefail

label="com.salesnow.form-runner.chrome"
source_plist="$(cd "$(dirname "$0")" && pwd)/${label}.plist"
target_dir="$HOME/Library/LaunchAgents"
target_plist="$target_dir/${label}.plist"
domain="gui/$(id -u)"

mkdir -p "$target_dir" "$HOME/.form-runner"
plutil -lint "$source_plist" >/dev/null
cp "$source_plist" "$target_plist"
launchctl bootout "$domain/$label" 2>/dev/null || true
launchctl bootstrap "$domain" "$target_plist"
launchctl kickstart -k "$domain/$label"
print "Installed ${label}. Chrome availability will be checked every 60 seconds."
