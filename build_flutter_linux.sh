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

# 保存当前目录
PROJECT_ROOT=$(pwd)

# 构建 agentassistant-srv
echo "Building agentassistant-srv..."
go build -o flutterclient/agentassistant-srv ./cmd/agentassistant-srv

# 设置执行权限
chmod +x flutterclient/agentassistant-srv

# 进入 Flutter 项目目录
cd flutterclient

# 清理旧的构建
echo "Cleaning old build..."
flutter clean

# 获取依赖
echo "Getting dependencies..."
flutter pub get

# 构建 Linux 应用
echo "Building Linux app..."
flutter build linux --release

# 复制 agentassistant-srv 到构建目录
echo "Copying agentassistant-srv to build directory..."
cp "$PROJECT_ROOT/flutterclient/agentassistant-srv" build/linux/x64/release/bundle/

# 设置执行权限
chmod +x build/linux/x64/release/bundle/agentassistant-srv

echo "Build completed successfully!"
echo "You can find the application in: build/linux/x64/release/bundle/" 