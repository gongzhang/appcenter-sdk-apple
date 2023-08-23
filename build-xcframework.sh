#!/bin/zsh

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

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

# a function that fix macOS framework (symlink to real file)
function fix_xcframework() {
  local name="$1"
  cp -HR "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/$name.framework" "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/tmp"
  rm "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/$name.framework"
  mv "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/tmp" "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/$name.framework"
}

# a function that copy the macos framework to correct location (and remove wrong symlink)
function fix_xcframework2() {
  local name="$1"
  # cp -rP "AppCenter-SDK-Apple/macOS/$name.framework" "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/"
  cp -HR "AppCenter-SDK-Apple/macOS/$name.framework" "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/tmp"
  rm "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/$name.framework"
  mv "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/tmp" "AppCenter-SDK-Apple/XCFramework/$name.xcframework/macos-arm64_x86_64/$name.framework"
}

fix_xcframework2 AppCenter
fix_xcframework2 AppCenterAnalytics
fix_xcframework2 AppCenterCrashes

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1.0" "./AppCenter/AppCenter/Support/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1.0" "./AppCenterCrashes/AppCenterCrashes/Support/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1.0" "./AppCenterAnalytics/AppCenterAnalytics/Support/Info.plist"

# create carthage zip
cd AppCenter-SDK-Apple/XCFramework
7z a -mx=9 Carthage.xcframework.zip AppCenter.xcframework AppCenterAnalytics.xcframework AppCenterCrashes.xcframework
cd ../..

open AppCenter-SDK-Apple
echo "Done."
