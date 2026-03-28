@echo off
echo Setting up Haxe Stack Platform Starter Template...

:: 1. Install Library Dependencies
echo Installing Haxe libraries...
haxelib install SideWinder
haxelib install haxeui-core
haxelib install haxeui-openfl
haxelib install haxeui-html5
haxelib install openfl
haxelib install actuate
haxelib install hx-injection
haxelib install Json2Object

:: 2. Setup Configuration
if not exist "..\config\.env" (
    echo Creating .env from template...
    copy "..\config\.env.example" "..\config\.env"
    echo PLEASE EDIT config\.env with your Stack Platform API Key!
)

echo Setup Complete.
pause
