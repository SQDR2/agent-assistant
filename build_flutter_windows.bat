@echo off
setlocal enabledelayedexpansion

:: 检查是否在项目根目录
if not exist "go.mod" (
    echo Error: Please run this script from the project root directory
    exit /b 1
)

:: 保存当前目录
set "PROJECT_ROOT=%CD%"

:: 构建 agentassistant-srv
echo Building agentassistant-srv...
go build -o flutterclient\agentassistant-srv.exe .\cmd\agentassistant-srv

:: 进入 Flutter 项目目录
cd flutterclient

:: 清理旧的构建
echo Cleaning old build...
flutter clean

:: 获取依赖
echo Getting dependencies...
flutter pub get

:: 构建 Windows 应用
echo Building Windows app...
flutter build windows --release

:: 复制 agentassistant-srv.exe 到构建目录
echo Copying agentassistant-srv.exe to build directory...
copy "%PROJECT_ROOT%\flutterclient\agentassistant-srv.exe" build\windows\runner\Release\

echo Build completed successfully!
echo You can find the application in: build\windows\runner\Release\ 