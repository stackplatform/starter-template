# Universal build script (PowerShell version)
# Detects platform and runs appropriate build
# Usage: powershell -File scripts\build.ps1 [platform] [arch]

param(
    [string]$Platform = "auto",
    [string]$Arch = "x64"
)

$ErrorActionPreference = "Stop"

# Auto-detect platform if not specified
if ($Platform -eq "auto") {
    $osInfo = Get-CimInstance Win32_OperatingSystem
    if ($osInfo.Caption -like "*Windows*") {
        $Platform = "windows"
    }
    elseif ($osInfo.Caption -like "*Linux*") {
        $Platform = "linux"
    }
    elseif ($osInfo.Caption -like "*macOS*" -or $osInfo.Caption -like "*Darwin*") {
        $Platform = "macos"
    }
    else {
        Write-Error "Unknown platform: $($osInfo.Caption)"
        exit 1
    }
}

Write-Host "Building for $Platform $Arch..."

switch ($Platform) {
    "windows" {
        if (Test-Path "scripts\build-windows-x64.ps1") {
            & "scripts\build-windows-x64.ps1"
        }
        else {
            Write-Error "Build script not found: scripts\build-windows-x64.ps1"
            exit 1
        }
    }
    "linux" {
        if (Test-Path "scripts\build-linux-x64.sh") {
            bash scripts/build-linux-x64.sh
        }
        else {
            Write-Error "Build script not found: scripts\build-linux-x64.sh"
            exit 1
        }
    }
    "macos" {
        if (Test-Path "scripts\build-macos-x64.sh") {
            bash scripts/build-macos-x64.sh
        }
        else {
            Write-Error "Build script not found: scripts\build-macos-x64.sh"
            exit 1
        }
    }
    default {
        Write-Error "Unknown platform: $Platform"
        exit 1
    }
}

Write-Host ""
Write-Host "✓ Build complete!"
Write-Host "Find your artifacts in: dist/"
