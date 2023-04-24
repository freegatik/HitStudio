#!/usr/bin/env bash
# Run xcodebuild against a concrete iOS Simulator (avoids "iPhone 16" + OS:latest ambiguity).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
DEST="${IOS_DESTINATION:-platform=iOS Simulator,name=iPhone 16,OS=18.6}"
exec xcodebuild -project HitStudio.xcodeproj -scheme HitStudio -destination "$DEST" "$@"
