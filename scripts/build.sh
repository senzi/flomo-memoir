#!/bin/bash

# 确保脚本在错误时退出
set -e

# 颜色输出
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 创建 Release 目录
echo -e "${GREEN}创建 Release 目录...${NC}"
mkdir -p Release

# 配置 Tauri 构建选项，禁用自动打开 DMG
export TAURI_BUNDLE_DMG_AUTO_OPEN=false

# 构建应用
echo -e "${GREEN}构建应用...${NC}"
pnpm install
pnpm tauri build

# 获取版本号（从 Cargo.toml）
VERSION=$(grep '^version =' src-tauri/Cargo.toml | cut -d '"' -f2)
echo "当前版本: ${VERSION}"

# 复制并重命名构建文件到 Release 目录
echo -e "${GREEN}移动构建文件到 Release 目录...${NC}"

# macOS ARM64
if [ -f "src-tauri/target/release/bundle/dmg/flomo-memoir_${VERSION}_aarch64.dmg" ]; then
    echo "复制 macOS ARM64 DMG..."
    cp "src-tauri/target/release/bundle/dmg/flomo-memoir_${VERSION}_aarch64.dmg" "Release/flomo-memoir_${VERSION}_mac_arm64.dmg"
fi

# macOS x64
if [ -f "src-tauri/target/release/bundle/dmg/flomo-memoir_${VERSION}_x64.dmg" ]; then
    echo "复制 macOS x64 DMG..."
    cp "src-tauri/target/release/bundle/dmg/flomo-memoir_${VERSION}_x64.dmg" "Release/flomo-memoir_${VERSION}_mac_x64.dmg"
fi

# Windows x64
if [ -f "src-tauri/target/release/bundle/msi/flomo-memoir_${VERSION}_x64_en-US.msi" ]; then
    echo "复制 Windows x64 MSI..."
    cp "src-tauri/target/release/bundle/msi/flomo-memoir_${VERSION}_x64_en-US.msi" "Release/flomo-memoir_${VERSION}_windows_x64.msi"
fi

# Windows ARM64
if [ -f "src-tauri/target/release/bundle/msi/flomo-memoir_${VERSION}_arm64_en-US.msi" ]; then
    echo "复制 Windows ARM64 MSI..."
    cp "src-tauri/target/release/bundle/msi/flomo-memoir_${VERSION}_arm64_en-US.msi" "Release/flomo-memoir_${VERSION}_windows_arm64.msi"
fi

# 检查是否有文件被复制到 Release 目录
if [ -z "$(ls -A Release)" ]; then
    echo -e "\n${GREEN}警告：Release 目录为空${NC}"
    echo "构建文件可能位于以下位置："
    echo "macOS: src-tauri/target/release/bundle/dmg/"
    echo "Windows: src-tauri/target/release/bundle/msi/"
    find src-tauri/target/release/bundle -type f -name "flomo-memoir*"
else
    echo -e "\n${GREEN}构建完成！${NC}"
    echo "构建文件已移动到 Release 目录，包含以下文件："
    ls -l Release
fi
