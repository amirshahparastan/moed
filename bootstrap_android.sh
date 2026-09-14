#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter در PATH پیدا نشد"
  exit 1
fi

SAFE_DIR="$(mktemp -d)"
trap 'rm -rf "$SAFE_DIR"' EXIT
cp -R lib assets tooling "$SAFE_DIR/"
cp pubspec.yaml analysis_options.yaml "$SAFE_DIR/"

flutter create --platforms=android --org ir.wearepulse --project-name moed .

rm -rf lib assets tooling
cp -R "$SAFE_DIR/lib" ./lib
cp -R "$SAFE_DIR/assets" ./assets
cp -R "$SAFE_DIR/tooling" ./tooling
cp "$SAFE_DIR/pubspec.yaml" ./pubspec.yaml
cp "$SAFE_DIR/analysis_options.yaml" ./analysis_options.yaml

mkdir -p android/app/src/main/kotlin/ir/wearepulse/moed
cp tooling/MainActivity.kt android/app/src/main/kotlin/ir/wearepulse/moed/MainActivity.kt
cp tooling/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
python3 tooling/patch_android.py

flutter pub get
dart run flutter_launcher_icons

echo "✅ پروژه Android آماده شد"
echo "APK تست: flutter build apk --release"
echo "اجرا با کابل/ADB: flutter run"
