#!/bin/bash

# 设置错误时退出
set -e

# 显示执行的命令
set -x

# 确保在项目根目录
if [ ! -f "go.mod" ]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

# 构建 agentassistant-srv
echo "Building agentassistant-srv..."
go build -o flutterclient/agentassistant-srv ./cmd/agentassistant-srv

# 构建 agentassistant-mcp
echo "Building agentassistant-mcp..."
go build -o agentassistant-mcp ./cmd/agentassistant-mcp

# 设置执行权限
chmod +x flutterclient/agentassistant-srv
chmod +x agentassistant-mcp

echo "Build completed successfully!" 