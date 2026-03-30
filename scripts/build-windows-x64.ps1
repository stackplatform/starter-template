# Build script for Windows x64 (PowerShell version)
# Usage: powershell -File scripts\build-windows-x64.ps1

param(
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

Write-Host "Building for Windows x64..."

# Create build directory
$buildDir = "dist"
if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

# Clean previous builds
$zipFile = "dist/app-windows-x64.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

# Compile Haxe application
Write-Host "Compiling..."
$compileResult = haxe build-windows-x64.hxml
if ($LASTEXITCODE -ne 0) {
    Write-Error "Compilation failed"
    exit 1
}

# Package into zip
Write-Host "Packaging..."
if (Test-Path "bin") {
    # PowerShell 5.0+ includes Compress-Archive
    try {
        Compress-Archive -Path "bin" -DestinationPath $zipFile -Force
    }
    catch {
        Write-Error "Failed to create zip: $_"
        exit 1
    }
}
elseif (Test-Path "bin/server.exe") {
    Compress-Archive -Path "bin/server.exe" -DestinationPath $zipFile -Force
}
else {
    Write-Error "Error: No compiled output found in bin\"
    exit 1
}

# Verify zip is valid
Write-Host "Verifying..."
try {
    $shell = New-Object -ComObject Shell.Application
    $zipItem = $shell.NameSpace($zipFile)
    if ($zipItem.Items().Count -eq 0) {
        Write-Error "Zip file is empty or invalid"
        exit 1
    }
}
catch {
    Write-Warning "Could not verify zip (may require Windows Explorer), but file was created"
}

Write-Host "✓ Build complete: $zipFile"
$fileInfo = Get-Item $zipFile
Write-Host "  Size: $($fileInfo.Length / 1MB -as [int])MB"
