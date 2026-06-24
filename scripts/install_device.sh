#!/bin/bash
#
# Builds PICHY and installs it onto a connected iPhone over cable using a free
# (personal-team) Apple Development signing setup — no paid program required.
#
# Notes:
#  * Builds of a personal team expire after 7 days; just re-run this to refresh.
#  * This project lives in a cloud-synced folder, which stamps extended
#    attributes onto build artifacts and makes codesign fail with
#    "resource fork, Finder information, or similar detritus not allowed".
#    We strip xattrs from the source and build to DerivedData OUTSIDE the
#    synced folder to avoid that.
#
# Usage:  scripts/install_device.sh [device-udid]
# If no UDID is given, the first connected device is used.
#
set -euo pipefail
cd "$(dirname "$0")/.."

SCHEME="PICHY"
BUNDLE_ID="communityjvl.PICHY"
DERIVED="${TMPDIR:-/tmp}/pichy-device-build"

# Resolve the target device.
UDID="${1:-}"
if [[ -z "$UDID" ]]; then
  UDID=$(xcrun xctrace list devices 2>&1 \
    | grep -iE "iphone|ipad" | grep -v "Simulator" \
    | head -1 | sed -E 's/.*\(([0-9A-Fa-f-]{25,})\).*/\1/')
fi
if [[ -z "$UDID" ]]; then
  echo "❌ No connected device found. Plug in the iPhone and trust this Mac." >&2
  exit 1
fi
echo "▶︎ Target device: $UDID"

echo "▶︎ Stripping stray extended attributes from source…"
xattr -cr PICHY PICHY.xcodeproj 2>/dev/null || true

echo "▶︎ Building + signing for device…"
xcodebuild -scheme "$SCHEME" \
  -destination "id=$UDID" \
  -allowProvisioningUpdates \
  -derivedDataPath "$DERIVED" \
  build

APP="$DERIVED/Build/Products/Debug-iphoneos/$SCHEME.app"
echo "▶︎ Installing $APP…"
xcrun devicectl device install app --device "$UDID" "$APP"

echo "▶︎ Launching…"
xcrun devicectl device process launch --device "$UDID" "$BUNDLE_ID" || true

echo "✅ Done. If the app shows 'Untrusted Developer', go to"
echo "   Settings → General → VPN & Device Management → trust the developer, then reopen."
