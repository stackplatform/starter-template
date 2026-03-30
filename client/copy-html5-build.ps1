# Post-build script for Stack Platform Client
$sourceDir = "Export\html5\bin"
$destinations = @(
    "..\server\static\platform",
    "..\server\Export\hl\bin\static\platform"
)

foreach ($destDir in $destinations) {
    # Ensure destination directory exists
    if (-Not (Test-Path $destDir)) { 
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null 
    }

    # Delete existing files and directories in destination
    Get-ChildItem -Path $destDir -Recurse | Remove-Item -Force -Recurse
    Write-Host "Cleaned destination directory: $destDir" -ForegroundColor Yellow

    # Copy new build
    if (Test-Path "$sourceDir") {
        Copy-Item -Path "$sourceDir\*" -Destination $destDir -Recurse -Force
        Write-Host "Copied client HTML5 build to: $destDir" -ForegroundColor Green
    } else {
        Write-Host "Source directory not found: $sourceDir" -ForegroundColor Red
    }
}
