#!/bin/zsh
set -e

export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"

xcodebuild \
  -scheme "AppCenter" \
  -configuration "Release" \
  -destination generic/platform=iOS

xcodebuild \
  -scheme "AppCenterAnalytics" \
  -configuration "Release" \
  -destination generic/platform=iOS

xcodebuild \
  -scheme "AppCenterCrashes" \
  -configuration "Release" \
  -destination generic/platform=iOS
