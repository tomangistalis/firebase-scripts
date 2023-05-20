#!/bin/bash

# Check if the version parameter was passed
if [ -z "$1" ]; then
    echo "Error: version parameter is missing"
    exit 1
fi

# Get the version parameter from the command line argument
VERSION="$1"
URL="https://github.com/tomangistalis/firebase-ios-sdk/releases/download/${VERSION}/"
DOWNLOADS="downloads"
FRAMEWORKS="frameworks"

# Create the DOWNLOADS if it doesn't exist
if [ ! -d "$DOWNLOADS" ]; then
    mkdir -p "$DOWNLOADS"
fi

if [ ! -d "$FRAMEWORKS" ]; then
    mkdir -p "$FRAMEWORKS"
fi

ROOT=$(pwd)

cd $DOWNLOADS

# Download and unzip the realm-swift release
curl -LO "https://github.com/firebase/firebase-ios-sdk/releases/download/${VERSION}/Firebase.zip"

# echo "Unzipping Firebase.zip"
unzip -q "Firebase.zip"

# Zip every .xcframework file inside
cd "Firebase"

for framework in $(find . -name '*.xcframework'); do
    echo "Zipping ${framework}"
    zip -r -q "${framework}.zip" "${framework}"
done

for zipfile in $(find . -name '*.xcframework.zip'); do
    echo "Copying ${zipfile}"
    cp $zipfile $ROOT/$FRAMEWORKS
done

cd $ROOT/frameworks

# # Run swift package compute-checksum for every zipped file and print the result
for zipfile in $(find . -name '*.xcframework.zip'); do
    checksum=$(swift package compute-checksum "${zipfile}")
    echo "${zipfile}: ${checksum}"
done

for zipfile in *.xcframework.zip; do
    checksum=$(swift package compute-checksum "${zipfile}")
    echo ".binaryTarget(name: \"${zipfile%.xcframework.zip}\", url: \"${URL}${zipfile}\", checksum: \"${checksum}\"),"
done

echo "Done."