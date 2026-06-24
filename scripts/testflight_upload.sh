#!/bin/bash
#
# Archives PICHY and uploads it to App Store Connect / TestFlight using an
# App Store Connect API key. Automatic signing + -allowProvisioningUpdates lets
# Xcode create the Apple Distribution certificate and provisioning profile on
# the fly, so no manual certificate setup is required.
#
# Required environment variables:
#   ASC_KEY_ID     – App Store Connect API Key ID (e.g. ABCD123456)
#   ASC_ISSUER_ID  – Issuer ID (UUID from Users and Access → Integrations)
# Optional:
#   ASC_KEY_PATH   – path to the .p8 (default: ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8)
#
set -euo pipefail
cd "$(dirname "$0")/.."

: "${ASC_KEY_ID:?Set ASC_KEY_ID}"
: "${ASC_ISSUER_ID:?Set ASC_ISSUER_ID}"
KEY_PATH="${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8}"

if [[ ! -f "$KEY_PATH" ]]; then
  echo "❌ API key not found at: $KEY_PATH" >&2
  exit 1
fi

SCHEME="PICHY"
ARCHIVE_PATH="build/PICHY.xcarchive"
EXPORT_PATH="build/export"

AUTH=(-allowProvisioningUpdates
      -authenticationKeyPath "$KEY_PATH"
      -authenticationKeyID "$ASC_KEY_ID"
      -authenticationKeyIssuerID "$ASC_ISSUER_ID")

echo "▶︎ Archiving…"
xcodebuild -scheme "$SCHEME" \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  "${AUTH[@]}" \
  clean archive

echo "▶︎ Exporting + uploading to App Store Connect…"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist scripts/ExportOptions.plist \
  -exportPath "$EXPORT_PATH" \
  "${AUTH[@]}"

echo "✅ Upload submitted. The build will appear in TestFlight after Apple finishes processing (usually 5–30 min)."
