#!/usr/bin/env bash
set -e

# Auto-reverse port 8000 if an Android device is connected via USB/ADB
if command -v adb >/dev/null 2>&1; then
  if adb devices | grep -E -q '[a-zA-Z0-9]+\s+device$'; then
    echo "⚡ Detected connected Android device. Setting up port forward (adb reverse tcp:8000 tcp:8000)..."
    adb reverse tcp:8000 tcp:8000 || true
  fi
fi

# Run flutter
flutter run "$@"
