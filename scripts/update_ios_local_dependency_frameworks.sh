#!/bin/bash

export BASEDIR="$(pwd)"

cd ${BASEDIR}/../ios/test-app-local-dependency || exit 1
rm -rf *.framework || exit 1
rm -rf *.xcframework || exit 1
find ${BASEDIR}/../../ffmpeg-kit/prebuilt/bundle-apple-framework-ios -name "*.framework" -exec cp -R {} . \; || exit 1
