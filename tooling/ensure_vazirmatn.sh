#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
FONT_DIR="assets/fonts"
FONT_FILE="$FONT_DIR/Vazirmatn.ttf"
mkdir -p "$FONT_DIR"
if [ ! -s "$FONT_FILE" ]; then
  echo "Downloading Vazirmatn font for the build..."
  URL="https://github.com/google/fonts/raw/main/ofl/vazirmatn/Vazirmatn%5Bwght%5D.ttf"
  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 3 -o "$FONT_FILE" "$URL"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$FONT_FILE" "$URL"
  else
    echo "curl/wget not found; cannot fetch Vazirmatn."
    exit 1
  fi
fi
