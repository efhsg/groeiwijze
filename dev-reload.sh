#!/bin/bash
# Live-reload development server via browser-sync + Tailscale
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# --- Dependency checks ---
MISSING=()
for cmd in tailscale jq npx; do
  command -v "$cmd" >/dev/null || MISSING+=("$cmd")
done
if [ ${#MISSING[@]} -gt 0 ]; then
  echo "Missing dependencies: ${MISSING[*]}"
  echo "Install these before running this script."
  exit 1
fi

# --- Cleanup on exit ---
cleanup() {
  echo ""
  echo "Stopping Tailscale serve..."
  tailscale serve --https=3443 off 2>/dev/null || true
  echo "Done."
}
trap cleanup EXIT

# --- Configure Tailscale serve ---
HOSTNAME=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')
tailscale serve --bg --https=3443 http://localhost:3000

echo ""
echo "=== Live-reload development server ==="
echo ""
echo "Remote URL: https://$HOSTNAME:3443"
echo "Local URL:  http://localhost:3000"
echo ""
echo "Watching: website/**/*.{html,css,js,svg,png}"
echo "Press Ctrl+C to stop."
echo ""

# --- Start browser-sync (foreground, so Ctrl+C stops it) ---
npx browser-sync@3 start \
  --server website \
  --files "website/**/*.html, website/**/*.css, website/**/*.js, website/assets/img/*" \
  --port 3000 \
  --no-open \
  --no-notify
