#!/bin/bash

# Log 系統工具函數
# 用途：為診斷工具提供統一的 log 記錄功能

# 取得專案根目錄
LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/logs/$(date '+%Y%m%d')"

# 建立 log 目錄
mkdir -p "$LOG_DIR"

# 開始記錄函數
start_log() {
    local script_path=$1
    local script_name=$(basename "$script_path" .sh)
    
    # 產生 log 檔案路徑：script_name_HHMMSS.log
    LOG_FILE="$LOG_DIR/${script_name}_$(date '+%H%M%S').log"
    
    # 使用 tee 同時輸出到終端和檔案
    exec > >(tee -a "$LOG_FILE")
    exec 2>&1
    
    # 顯示 log 檔案位置
    echo "Log 記錄: $LOG_FILE"
    echo "開始時間: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================="
    echo ""
}