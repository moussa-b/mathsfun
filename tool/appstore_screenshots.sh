#!/usr/bin/env bash
# Captures the App Store screenshots in EN and FR on one simulator.
# Usage: tool/appstore_screenshots.sh <simulator-udid> <output-folder-name> [languages]
#   e.g. tool/appstore_screenshots.sh C4D3FDD9-... iphone-6.9
set -euo pipefail
cd "$(dirname "$0")/.."

udid="$1"
folder="$2"
languages="${3:-en fr}"

xcrun simctl boot "$udid" 2>/dev/null || true
xcrun simctl status_bar "$udid" override --time "9:41" --batteryState discharging \
  --batteryLevel 100 --cellularBars 4 --wifiBars 3 --dataNetwork wifi

for lang in $languages; do
  out="appstore/screenshots/$folder/$lang"
  mkdir -p "$out"
  fvm flutter test integration_test/app_store_screenshots_test.dart -d "$udid" \
    --dart-define=SHOT_LANG="$lang" 2>&1 |
    while IFS= read -r line; do
      echo "$line"
      if [[ "$line" =~ SHOT:([a-z0-9_]+) ]]; then
        name="${BASH_REMATCH[1]}"
        xcrun simctl io "$udid" screenshot --type=png "$out/$name.png" >/dev/null 2>&1
        # App Store Connect rejects screenshots with an alpha channel.
        sips -s format jpeg "$out/$name.png" --out "$out/$name.jpg" >/dev/null &&
          sips -s format png "$out/$name.jpg" --out "$out/$name.png" >/dev/null &&
          rm "$out/$name.jpg"
        echo ">> captured $out/$name.png"
      fi
    done
done
