#!/bin/bash

export BASEDIR="$(pwd)"

cd ${BASEDIR}/../tvos/test-app-local-dependency || exit 1
rm -rf *.xcframework || exit 1
find ${BASEDIR}/../../ffmpeg-kit/prebuilt/bundle-apple-xcframework-tvos -name "*.xcframework" -exec cp -r {} . \; || exit 1
