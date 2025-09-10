#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "==================================="
echo "   影音串流網路診斷 v1.0"
echo "==================================="
echo "時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "WARP 狀態: $(warp-cli status | grep -o 'Connected\|Disconnected')"
echo ""

echo "【串流平台連線測試】"
echo "-----------------------------------"

# 測試各平台延遲
platforms=(
    "facebook.com:Facebook"
    "youtube.com:YouTube"
    "www.netflix.com:Netflix"
    "www.twitch.tv:Twitch"
    "video.h5.weibo.cn:微博影片"
)

for platform in "${platforms[@]}"; do
    IFS=':' read -r host name <<< "$platform"
    printf "%-15s: " "$name"
    
    result=$(ping -c 5 -W 2 $host 2>/dev/null | tail -1)
    if echo "$result" | grep -q "100.0% packet loss\|100% packet loss"; then
        echo -e "${RED}無法連線${NC}"
    else
        avg=$(echo "$result" | awk -F'/' '{print $5}' | cut -d' ' -f1)
        if [ -z "$avg" ]; then
            echo -e "${YELLOW}不穩定${NC}"
        elif (( $(echo "$avg < 50" | bc -l) )); then
            echo -e "${GREEN}${avg}ms${NC}"
        else
            echo -e "${YELLOW}${avg}ms (偏高)${NC}"
        fi
    fi
done

echo ""
echo "【CDN 節點速度測試】"
echo "-----------------------------------"

# 測試 CDN 速度
test_cdn() {
    local url=$1
    local name=$2
    printf "%-15s: " "$name"
    
    # 測試 3 次取平均
    total=0
    count=0
    
    for i in {1..3}; do
        speed=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 5 "$url" 2>/dev/null)
        if [ ! -z "$speed" ] && [ "$speed" != "0" ]; then
            total=$(echo "$total + $speed" | bc)
            count=$((count + 1))
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo -e "${RED}測試失敗${NC}"
    else
        avg_speed=$(echo "scale=2; $total / $count / 1024" | bc)
        if (( $(echo "$avg_speed < 100" | bc -l) )); then
            echo -e "${RED}${avg_speed} KB/s (極慢)${NC}"
        elif (( $(echo "$avg_speed < 500" | bc -l) )); then
            echo -e "${YELLOW}${avg_speed} KB/s (偏慢)${NC}"
        else
            echo -e "${GREEN}${avg_speed} KB/s${NC}"
        fi
    fi
}

test_cdn "https://www.facebook.com" "FB 首頁"
test_cdn "https://static.xx.fbcdn.net/rsrc.php/v3/y4/r/Ard0j8TfLbH.js" "FB CDN"
test_cdn "https://www.youtube.com" "YT 首頁"
test_cdn "https://i.ytimg.com/generate_204" "YT CDN"

echo ""
echo "【影片載入模擬】"
echo "-----------------------------------"

# 測試較大檔案
echo "測試 10MB 檔案下載速度..."
speed=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 10 "https://speed.cloudflare.com/__down?bytes=10000000" 2>/dev/null)
if [ ! -z "$speed" ] && [ "$speed" != "0" ]; then
    speed_mb=$(echo "scale=2; $speed / 1024 / 1024" | bc)
    echo -n "下載速度: "
    if (( $(echo "$speed_mb < 1" | bc -l) )); then
        echo -e "${RED}${speed_mb} MB/s (無法流暢播放 HD)${NC}"
    elif (( $(echo "$speed_mb < 3" | bc -l) )); then
        echo -e "${YELLOW}${speed_mb} MB/s (可播放 720p)${NC}"
    else
        echo -e "${GREEN}${speed_mb} MB/s (可播放 1080p+)${NC}"
    fi
fi

echo ""
echo "【建議影片品質】"
echo "-----------------------------------"
if [ ! -z "$speed_mb" ]; then
    if (( $(echo "$speed_mb < 0.5" | bc -l) )); then
        echo "建議: 360p 或更低"
    elif (( $(echo "$speed_mb < 1" | bc -l) )); then
        echo "建議: 480p"
    elif (( $(echo "$speed_mb < 2.5" | bc -l) )); then
        echo "建議: 720p"
    elif (( $(echo "$speed_mb < 5" | bc -l) )); then
        echo "建議: 1080p"
    else
        echo "建議: 1080p 或 4K"
    fi
fi

echo ""
echo "完成時間: $(date '+%Y-%m-%d %H:%M:%S')"

