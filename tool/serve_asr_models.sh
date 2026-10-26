#!/usr/bin/env bash
# Serves build/asr/ (from tool/build_asr_models.sh) to a USB-connected Android
# phone, so the voice mode can be tested before the models are published.
# Run the app with --dart-define=SPEECH_MODEL_BASE_URL=http://127.0.0.1:8765/asr
set -euo pipefail
cd "$(dirname "$0")/../build"
[ -f asr/manifest-v1.json ] || { echo "build/asr is missing: run tool/build_asr_models.sh first" >&2; exit 1; }
adb="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
"$adb" reverse tcp:8765 tcp:8765
echo "Serving build/asr on http://127.0.0.1:8765/asr (phone → Mac via adb reverse)"
exec python3 -m http.server 8765 --bind 127.0.0.1
