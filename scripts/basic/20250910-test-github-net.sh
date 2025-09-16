#!/bin/bash

# 載入 log 系統
source "$(dirname "$0")/../utils/log.sh"
start_log "$0"

echo "=== GitHub 網路診斷 ==="
echo "時間: $(date)"
echo ""

echo "1. 測試問題節點 (Microsoft Azure 入口)"
echo "----------------------------------------"
ping -c 10 104.44.32.95 | tail -3
echo ""

echo "2. 測試 GitHub 主站"
echo "----------------------------------------"
ping -c 10 github.com | tail -3
echo ""

echo "3. 對照組：台灣本地"
echo "----------------------------------------"
ping -c 10 168.95.1.1 | tail -3  # HiNet DNS
echo ""

echo "4. 對照組：國際穩定節點"
echo "----------------------------------------"
ping -c 10 8.8.8.8 | tail -3      # Google DNS
echo ""

echo "5. 測試其他 Microsoft 服務"
echo "----------------------------------------"
ping -c 10 azure.microsoft.com | tail -3
echo ""

echo "6. 測試其他 Git 服務"
echo "----------------------------------------"
ping -c 10 gitlab.com | tail -3
echo ""

echo "=== 總結 ==="
echo "如果 #1 和 #2 封包遺失率高，但 #3 #4 正常"
echo "表示 HiNet 到 Microsoft/GitHub 的路徑有問題"
