@echo off
REM Run the Client with the Automatic Updater (HashLink)
cd /d "%~dp0"

if not exist "Export\hl\bin\Client.exe" (
    echo Error: Client has not been built yet. Run 'lime build hl' first.
    pause
    exit /b
)

cd Export\hl\bin
.\Client.exe updater.hl
pause
