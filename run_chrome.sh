#!/bin/bash
set -e
cd "$(dirname "$0")"
flutter pub get
flutter run -d chrome --web-port 7357
