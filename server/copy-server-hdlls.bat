@echo off
rem Copy necessary DLLs/HDLLs to the Export folder for the Starter Template Server

set TARGET_BIN=Export\hl\bin
if not "%~1"=="" set TARGET_BIN=%~1

if not exist "%TARGET_BIN%" mkdir "%TARGET_BIN%"

echo [copy-server-hdlls.bat] Copying dlls to %TARGET_BIN%

rem SideWinder prebuilt DLLs
set PREBUILT_DIR=.haxelib\SideWinder\git\native\civetweb\prebuilt\windows
if exist "%PREBUILT_DIR%" (
    copy /Y "%PREBUILT_DIR%\civetweb.hdll" "%TARGET_BIN%\" >nul
    copy /Y "%PREBUILT_DIR%\sqlite.hdll" "%TARGET_BIN%\" >nul
) else (
    echo [copy-server-hdlls.bat] Warning: Prebuilt dir not found: %PREBUILT_DIR%
)

rem LIME HDLL (using relative path from project root)
rem Note: Version 8.3.1 is hardcoded here to match the main project's requirements.
set LIME_NDLL=.haxelib\lime\8,3,1\ndll\Windows64
if exist "%LIME_NDLL%\lime.hdll" (
    copy /Y "%LIME_NDLL%\lime.hdll" "%TARGET_BIN%\" >nul
) else (
    echo [copy-server-hdlls.bat] Warning: lime.hdll not found in %LIME_NDLL%
)
