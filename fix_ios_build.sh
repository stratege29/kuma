#!/bin/bash

echo "Fixing iOS build issue with unsupported -G compiler flag..."

# Navigate to iOS directory
cd ios

# Clean existing build artifacts
echo "Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf build/
rm -rf Pods/
rm -rf .symlinks/
rm Podfile.lock

# Clean Flutter build
echo "Cleaning Flutter build..."
cd ..
flutter clean

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Navigate back to iOS directory
cd ios

# Install pods with verbose output to debug issues
echo "Installing CocoaPods dependencies..."
pod install --verbose

# If pod install fails, try with repo update
if [ $? -ne 0 ]; then
    echo "Pod install failed, trying with repo update..."
    pod repo update
    pod install --verbose
fi

echo "Fix applied. Now try building your iOS app again."
echo "If the issue persists, you may need to:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Go to Build Settings for each target"
echo "3. Search for 'Other C Flags' and 'Other C++ Flags'"
echo "4. Remove any '-G' flags manually"