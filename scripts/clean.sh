#!/bin/bash

rm -rf ../android/.gradle
rm -rf ../android/build/
rm -rf ../android/test-app-local-dependency/build/
rm -rf ../android/test-app-maven-central/build/

rm -rf ../flutter/test-app-local-dependency/build
rm -rf ../flutter/test-app-local-dependency/android/.gradle
rm -rf ../flutter/test-app-local-dependency/ios/Pods
rm -rf ../flutter/test-app-local-dependency/macos/Pods
rm -rf ../flutter/test-app-local-dependency/.dart_tool
rm -rf ../flutter/test-app-local-dependency/.packages
rm -rf ../flutter/test-app-local-dependency/.flutter-plugins
rm -rf ../flutter/test-app-local-dependency/.flutter-plugins-dependencies
rm -rf ../flutter/test-app-pub/build
rm -rf ../flutter/test-app-pub/android/.gradle
rm -rf ../flutter/test-app-pub/ios/Pods
rm -rf ../flutter/test-app-pub/macos/Pods
rm -rf ../flutter/test-app-pub/.dart_tool
rm -rf ../flutter/test-app-pub/.packages
rm -rf ../flutter/test-app-pub/.flutter-plugins
rm -rf ../flutter/test-app-pub/.flutter-plugins-dependencies

rm -rf ../react-native/test-app-local-dependency/node_modules
rm -rf ../react-native/test-app-local-dependency/ios/build
rm -rf ../react-native/test-app-local-dependency/ios/Pods
rm -rf ../react-native/test-app-local-dependency/android/.gradle
rm -rf ../react-native/test-app-local-dependency/android/app/build
rm -rf ../react-native/test-app-npm/node_modules
rm -rf ../react-native/test-app-npm/ios/build
rm -rf ../react-native/test-app-npm/ios/Pods
rm -rf ../react-native/test-app-npm/android/.gradle
rm -rf ../react-native/test-app-npm/android/app/build
rm -rf ../react-native/test-app-npm-single-view/node_modules
rm -rf ../react-native/test-app-npm-single-view/ios/build
rm -rf ../react-native/test-app-npm-single-view/ios/Pods
rm -rf ../react-native/test-app-npm-single-view/android/.gradle
rm -rf ../react-native/test-app-npm-single-view/android/app/build

rm -rf ../ios/test-app-cocoapods/Pods
rm -rf ../ios/test-app-local-dependency/*.framework
rm -rf ../ios/test-app-local-dependency/*.xcframework

rm -rf ../macos/test-app-cocoapods/Pods
rm -rf ../macos/test-app-local-dependency/*.framework
rm -rf ../macos/test-app-local-dependency/*.xcframework

rm -rf ../tvos/test-app-cocoapods/Pods
rm -rf ../tvos/test-app-local-dependency/*.framework
rm -rf ../tvos/test-app-local-dependency/*.xcframework

rm -rf ../linux/test-app-local-dependency/build
