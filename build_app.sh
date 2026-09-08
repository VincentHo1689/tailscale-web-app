#!/bin/bash
set -e

if [ ! -f ".env" ]; then
    echo "ERROR: .env not found. Copy .env.example to .env and edit it first."
    exit 1
fi

set -a
source .env
set +a

for value in WEB_URL APP_NAME APP_PACKAGE TAILSCALE_HOSTNAME; do
    if [ -z "${!value:-}" ]; then
        echo "ERROR: Missing $value in .env."
        exit 1
    fi
done

manifest="android/app/src/main/AndroidManifest.xml"
app_name="${APP_NAME:-My App}"
escaped_app_name=$(printf '%s' "$app_name" | sed 's/[\/&]/\\&/g')
sed -i.bak "s#android:label=\"[^\"]*\"#android:label=\"$escaped_app_name\"#" "$manifest"
rm -f "$manifest.bak"

escaped_package=$(printf '%s' "$APP_PACKAGE" | sed 's/[\/&]/\\&/g')
sed -i.bak "s#applicationId = \"[^\"]*\"#applicationId = \"$escaped_package\"#" android/app/build.gradle.kts
rm -f android/app/build.gradle.kts.bak

flutter pub get
flutter build apk --release

echo "APK generated: build/app/outputs/flutter-apk/app-release.apk"
