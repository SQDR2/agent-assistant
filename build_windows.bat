@echo off
setlocal enabledelayedexpansion

:: 检查是否在项目根目录
if not exist "go.mod" (
    echo Error: Please run this script from the project root directory
    exit /b 1
)

:: 构建 agentassistant-srv
echo Building agentassistant-srv...
go build -o flutterclient\agentassistant-srv.exe .\cmd\agentassistant-srv

:: 构建 agentassistant-mcp
echo Building agentassistant-mcp...
go build -o agentassistant-mcp.exe .\cmd\agentassistant-mcp

echo Build completed successfully! 