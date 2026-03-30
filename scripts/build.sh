#!/bin/bash
# Universal build script - detects platform and runs appropriate build
# Usage: bash scripts/build.sh [platform] [arch]

set -e

PLATFORM=${1:-auto}
ARCH=${2:-x64}

# Auto-detect platform if not specified
if [ "$PLATFORM" = "auto" ]; then
    case "$(uname)" in
        Linux)
            PLATFORM="linux"
            ;;
        Darwin)
            PLATFORM="macos"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            PLATFORM="windows"
            ;;
        *)
            echo "Unknown platform: $(uname)"
            exit 1
            ;;
    esac
fi

echo "Building for $PLATFORM $ARCH..."

case "$PLATFORM" in
    linux)
        bash scripts/build-linux-x64.sh
        ;;
    windows)
        if command -v powershell &> /dev/null; then
            powershell -File scripts/build-windows-x64.ps1
        else
            # Fallback for bash on Windows
            bash scripts/build-windows-x64.sh
        fi
        ;;
    macos)
        bash scripts/build-macos-x64.sh
        ;;
    *)
        echo "Unknown platform: $PLATFORM"
        exit 1
        ;;
esac

echo ""
echo "✓ Build complete!"
echo "Find your artifacts in: dist/"
