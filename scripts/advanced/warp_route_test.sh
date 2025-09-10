#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "==================================="
echo "   WARP 路由比較測試"
echo "==================================="
echo ""

# 測試目標
targets=(
    "github.com"
    "google.com"
    "facebook.com"
    "1.1.1.1"
)

# 關閉 WARP 測試
echo -e "${YELLOW}【測試 1：無 WARP】${NC}"
echo "-----------------------------------"
warp-cli disconnect 2>/dev/null
sleep 2

echo "當前 IP："
curl -s -4 ifconfig.me
echo -e "\n"

for target in "${targets[@]}"; do
    echo -e "${BLUE}追蹤到 $target:${NC}"
    traceroute -n -m 10 -w 1 $target 2>/dev/null | head -12
    echo ""
done

# 開啟 WARP 測試
echo -e "${YELLOW}【測試 2：有 WARP】${NC}"
echo "-----------------------------------"
warp-cli connect 2>/dev/null
sleep 3

echo "當前 IP："
curl -s -4 ifconfig.me
echo -e "\n"

for target in "${targets[@]}"; do
    echo -e "${BLUE}追蹤到 $target:${NC}"
    traceroute -n -m 10 -w 1 $target 2>/dev/null | head -12
    echo ""
done

# 比較路由表
echo -e "${YELLOW}【路由表比較】${NC}"
echo "-----------------------------------"
echo "WARP 介面："
ifconfig | grep -A 5 utun | head -6

echo ""
echo "預設路由："
netstat -rn | grep -E "^default|^0/1" | head -5

echo ""
echo -e "${GREEN}測試完成${NC}"
echo "注意觀察："
echo "1. IP 位址變化"
echo "2. 第 2-3 跳的差異"
echo "3. * * * 表示隧道內部"
