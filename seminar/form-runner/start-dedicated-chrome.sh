#!/bin/zsh
set -euo pipefail

runner_root="${FORM_RUNNER_HOME:-$HOME/.form-runner}"
chrome_profile="$runner_root/chrome-profile"
chrome_log="$runner_root/chrome.log"
caffeinate_pid_file="$runner_root/caffeinate.pid"
debug_port="${FORM_RUNNER_DEBUG_PORT:-9222}"
chrome_app="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [[ ! -x "$chrome_app" ]]; then
  print -u2 "error: Google Chrome was not found at $chrome_app"
  exit 1
fi

mkdir -p "$runner_root" "$chrome_profile"

if curl --silent --fail "http://127.0.0.1:${debug_port}/json/version" >/dev/null 2>&1; then
  print "Form runner Chrome is already available on port ${debug_port}."
  exit 0
fi

# A dedicated profile keeps outreach logins separate from the user's everyday Chrome profile.
# Chrome must be the foreground process of its own launch. Wrapping it in caffeinate can
# terminate Chrome after its launcher process returns, so keep caffeinate as a separate daemon.
if [[ -f "$caffeinate_pid_file" ]] && kill -0 "$(<"$caffeinate_pid_file")" 2>/dev/null; then
  :
else
  nohup /usr/bin/caffeinate -dimsu >>"$chrome_log" 2>&1 &
  print -r -- "$!" >"$caffeinate_pid_file"
fi

# `open -na` detaches the macOS application from this short-lived launcher.
# This matters when the launcher is managed by launchd: direct child processes
# can otherwise be terminated when the launcher exits.
nohup /usr/bin/open -na "Google Chrome" --args \
  --remote-debugging-address=127.0.0.1 \
  --remote-debugging-port="$debug_port" \
  --user-data-dir="$chrome_profile" \
  --no-first-run \
  --no-default-browser-check \
  >>"$chrome_log" 2>&1 &

for _ in {1..20}; do
  if curl --silent --fail "http://127.0.0.1:${debug_port}/json/version" >/dev/null 2>&1; then
    print "Form runner Chrome started on port ${debug_port}."
    print "Complete any required logins in the dedicated Chrome window, then run the queue."
    exit 0
  fi
  sleep 1
done

print -u2 "error: Form runner Chrome did not become ready. See $chrome_log"
exit 1
