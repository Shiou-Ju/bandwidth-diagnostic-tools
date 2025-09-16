#!/bin/bash

# 載入 log 系統
source "$(dirname "$0")/../utils/log.sh"
start_log "$0"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "==================================="
echo "   GitHub 網路診斷工具 v2.0"
echo "==================================="
echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 基本 ping 測試
echo "【階段 1：連線品質測試】"
echo "-----------------------------------"

targets=(
    "192.168.8.1:本地路由器"
    "168.95.1.1:HiNet_DNS"
    "8.8.8.8:Google_DNS"
    "1.1.1.1:Cloudflare"
    "github.com:GitHub"
    "gitlab.com:GitLab"
)

for target in "${targets[@]}"; do
    IFS=':' read -r host desc <<< "$target"
    printf "%-20s: " "$desc"
    result=$(ping -c 5 -W 1 $host 2>/dev/null | tail -1)
    if echo "$result" | grep -q "100.0% packet loss"; then
        echo -e "${RED}無法連線${NC}"
    elif echo "$result" | grep -q "0.0% packet loss"; then
        avg=$(echo "$result" | awk -F'/' '{print $5}')
        echo -e "${GREEN}正常 (${avg}ms)${NC}"
    else
        loss=$(echo "$result" | grep -oE '[0-9.]+% packet loss' | cut -d'%' -f1)
        echo -e "${YELLOW}不穩定 (${loss}% 遺失)${NC}"
    fi
done

echo ""
echo "【階段 2：下載速度測試】"
echo "-----------------------------------"

# 測試下載速度
test_speed() {
    local url=$1
    local name=$2
    printf "%-20s: " "$name"
    
    speed=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 10 "$url" 2>/dev/null)
    if [ -z "$speed" ] || [ "$speed" = "0" ]; then
        echo -e "${RED}測試失敗${NC}"
    else
        speed_kb=$(echo "scale=2; $speed/1024" | bc)
        if (( $(echo "$speed_kb < 100" | bc -l) )); then
            echo -e "${RED}${speed_kb} KB/s (極慢)${NC}"
        elif (( $(echo "$speed_kb < 500" | bc -l) )); then
            echo -e "${YELLOW}${speed_kb} KB/s (偏慢)${NC}"
        else
            echo -e "${GREEN}${speed_kb} KB/s${NC}"
        fi
    fi
}

test_speed "https://github.com" "GitHub 首頁"
test_speed "https://raw.githubusercontent.com/torvalds/linux/master/README" "GitHub Raw"
test_speed "https://gitlab.com" "GitLab"
test_speed "https://www.google.com" "Google"

echo ""
echo "【階段 3：DNS 查詢速度】"
echo "-----------------------------------"

dns_servers=(
    "1.1.1.1:Cloudflare"
    "8.8.8.8:Google"
    "168.95.1.1:HiNet"
)

for dns in "${dns_servers[@]}"; do
    IFS=':' read -r server name <<< "$dns"
    printf "%-20s: " "$name"
    time=$(dig @$server github.com +stats | grep "Query time:" | awk '{print $4}')
    if [ -z "$time" ]; then
        echo -e "${RED}失敗${NC}"
    elif [ "$time" -lt 50 ]; then
        echo -e "${GREEN}${time} ms${NC}"
    else
        echo -e "${YELLOW}${time} ms${NC}"
    fi
done

echo ""
echo "【診斷結果】"
echo "-----------------------------------"

# 簡單分析
if ping -c 1 github.com &>/dev/null; then
    echo "✓ GitHub 可以連線"
else
    echo -e "${RED}✗ GitHub 無法連線${NC}"
fi

# 檢查 DNS
current_dns=$(networksetup -getdnsservers Wi-Fi | head -1)
echo "目前 DNS: $current_dns"

echo ""
echo "完成時間: $(date '+%Y-%m-%d %H:%M:%S')"
