@echo off
REM Build script for Windows x64
REM Usage: powershell -File scripts\build-windows-x64.ps1

setlocal enabledelayedexpansion

echo Building for Windows x64...

REM Create build directory
if not exist dist mkdir dist

REM Clean previous builds
if exist dist\app-windows-x64.zip del dist\app-windows-x64.zip

REM Compile Haxe application
echo Compiling...
haxe build-windows-x64.hxml
if errorlevel 1 (
    echo Compilation failed
    exit /b 1
)

REM Package into zip
echo Packaging...
if exist bin (
    powershell -Command "Compress-Archive -Path bin -DestinationPath dist\app-windows-x64.zip -Force"
) else if exist bin\server.exe (
    powershell -Command "Compress-Archive -Path bin\server.exe -DestinationPath dist\app-windows-x64.zip -Force"
) else (
    echo Error: No compiled output found in bin\
    exit /b 1
)

echo ✓ Build complete: dist\app-windows-x64.zip
dir dist\app-windows-x64.zip

endlocal
