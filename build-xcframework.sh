#!/bin/zsh

export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"

version=$(cat Package.swift | grep APP_CENTER_C_VERSION | grep -p '\d\.\d\.\d' -o)

echo "Build XCframework, version=$version"
echo "Do you want to continue? (y/n)"
read -r answer
case $answer in
    [yY][eE][sS]|[yY])
        echo "building..."
        ;;
    *)
        exit 0
        ;;
esac

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $version" "./AppCenter/AppCenter/Support/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $version" "./AppCenterCrashes/AppCenterCrashes/Support/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $version" "./AppCenterAnalytics/AppCenterAnalytics/Support/Info.plist"

xcodebuild archive \
  -scheme "All App Center Frameworks" \
  -configuration "Release" \
  -destination generic/platform=iOS

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1.0" "./AppCenter/AppCenter/Support/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1.0" "./AppCenterCrashes/AppCenterCrashes/Support/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1.0" "./AppCenterAnalytics/AppCenterAnalytics/Support/Info.plist"

echo "Done."
