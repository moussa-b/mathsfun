#!/usr/bin/env bash
# Prepares the speech recognition models of the Voice mode for the model host
# (nginx on the Coolify VPS behind mathsfun-models.bdzapps.com).
# Downloads the k2-fsa archives, keeps only the files the app loads, computes
# their sha256 and writes build/asr/ (manifest-v1.json included).
# Usage: tool/build_asr_models.sh <version>   e.g. tool/build_asr_models.sh v1
#
# A published <lang>/<version>/ folder is immutable: installed apps only
# re-download when the version changes, so a new model always needs a new
# version name, never an overwrite.
set -euo pipefail
cd "$(dirname "$0")/.."

version="${1:?usage: tool/build_asr_models.sh <version> (e.g. v1; never reuse a published one)}"
[[ "$version" =~ ^[A-Za-z0-9_-]{1,32}$ ]] || { echo "invalid version: $version" >&2; exit 1; }
releases="https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models"
out="build/asr"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

rm -rf "$out"
mkdir -p "$out"

# lang|archive (each archive ships encoder.onnx, decoder.onnx, joiner.onnx and
# tokens.txt; keep this list in sync with kSpeechModelFiles in
# lib/core/constants/speech_constants.dart)
models=(
  "fr|sherpa-onnx-streaming-zipformer-fr-kroko-2025-08-06"
  "en|sherpa-onnx-streaming-zipformer-en-kroko-2025-08-06"
)
files=(encoder.onnx decoder.onnx joiner.onnx tokens.txt)

manifest_entries=()
for entry in "${models[@]}"; do
  IFS='|' read -r lang archive <<<"$entry"
  echo "==> $lang: $archive"
  curl -fSL --retry 3 "$releases/$archive.tar.bz2" | tar xjf - -C "$work"
  src="$work/$archive"
  dst="$out/$lang/$version"
  mkdir -p "$dst"
  for name in "${files[@]}"; do cp "$src/$name" "$dst/$name"; done
  # Keep the model's own notice (the Kroko README points to its CC-BY-SA license).
  if [ -f "$src/README.md" ]; then cp "$src/README.md" "$dst/LICENSE.txt"; fi

  files_json=""
  for name in "${files[@]}"; do
    size=$(stat -f%z "$dst/$name" 2>/dev/null || stat -c%s "$dst/$name")
    sum=$(shasum -a 256 "$dst/$name" | cut -d' ' -f1)
    files_json+="${files_json:+,}{\"name\":\"$name\",\"size\":$size,\"sha256\":\"$sum\"}"
  done
  manifest_entries+=("\"$lang\":{\"version\":\"$version\",\"model\":\"$archive\",\"files\":[$files_json]}")
done

joined=$(IFS=,; echo "${manifest_entries[*]}")
echo "{\"schema\":1,\"languages\":{$joined}}" | python3 -m json.tool > "$out/manifest-v1.json"

echo
echo "Ready in $out:"
find "$out" -type f -exec ls -l {} \; | awk '{print $5, $NF}'
echo
echo "Upload to the VPS (folder served as /asr by the Coolify nginx), model files first:"
echo "  rsync -av --exclude manifest-v1.json $out/ <user>@<vps>:/srv/mathsfun-models/asr/"
echo "  rsync -av $out/manifest-v1.json <user>@<vps>:/srv/mathsfun-models/asr/"
echo "Never overwrite an already published <lang>/<version>/ folder."
