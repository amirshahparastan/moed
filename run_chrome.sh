#!/bin/bash
set -e
cd "$(dirname "$0")"
bash tooling/ensure_vazirmatn.sh
flutter pub get
flutter run -d chrome --web-port 7357
