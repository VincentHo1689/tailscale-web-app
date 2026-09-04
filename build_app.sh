#!/bin/bash
set -e

if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found. Please run ./setup.sh first."
    exit 1
fi

flutter pub get
flutter build apk --release

echo "APK Generated: build/app/outputs/flutter-apk/app-release.apk"
