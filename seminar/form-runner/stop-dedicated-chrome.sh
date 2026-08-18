#!/bin/zsh
set -euo pipefail

runner_root="${FORM_RUNNER_HOME:-$HOME/.form-runner}"
chrome_profile="$runner_root/chrome-profile"

# Match only the main Chrome process using this runner's dedicated profile.
runner_pids=("${(@f)$(ps -axo pid=,command= | awk -v profile="--user-data-dir=$chrome_profile" 'index($0, profile) && $0 ~ /Contents\/MacOS\/Google Chrome / && $0 !~ /Helper/ {print $1}')}")
if (( ${#runner_pids[@]} == 0 )); then
  print "Form runner Chrome is not running."
  exit 0
fi

for runner_pid in "${runner_pids[@]}"; do
  kill -0 "$runner_pid" 2>/dev/null && kill -TERM "$runner_pid" 2>/dev/null || true
done
print "Stopped form runner Chrome."
