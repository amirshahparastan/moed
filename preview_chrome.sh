#!/bin/bash
set -e
cd "$(dirname "$0")"
echo "▶ Moed Flutter Web Preview"
flutter pub get
flutter run -d chrome
