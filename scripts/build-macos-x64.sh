#!/bin/bash
# Build script for macOS x64
# Usage: bash scripts/build-macos-x64.sh

set -e  # Exit on error

echo "Building for macOS x64..."

# Create build directory
mkdir -p dist

# Clean previous builds
rm -f dist/app-macos-x64.zip

# Compile Haxe application
echo "Compiling..."
haxe build-macos-x64.hxml

# Package into zip
echo "Packaging..."
if [ -d "bin" ]; then
    zip -r dist/app-macos-x64.zip bin/
elif [ -f "bin/server" ]; then
    zip dist/app-macos-x64.zip bin/server
else
    echo "Error: No compiled output found in bin/"
    exit 1
fi

# Verify zip is valid
echo "Verifying..."
unzip -t dist/app-macos-x64.zip > /dev/null || exit 1

echo "✓ Build complete: dist/app-macos-x64.zip"
ls -lh dist/app-macos-x64.zip
