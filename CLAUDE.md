# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案概述
網路診斷工具集，專門用於解決 HiNet 路由與速度問題，特別針對 GitHub 連線緩慢問題 (55 KB/s) 和國際線路壅塞。專案包含測試 WARP VPN 效果的工具。

## 工具架構

### Basic 診斷工具
- `scripts/basic/20250910-test-github-net.sh` - 基本 GitHub 連線測試，測試問題節點 (Microsoft Azure)

### Advanced 診斷工具  
- `scripts/advanced/github_network_diagnostic_v2.sh` - 完整網路診斷工具（彩色輸出），包含連線品質和下載速度測試
- `scripts/advanced/video_streaming_test.sh` - 影音平台速度測試（YouTube, Netflix, Twitch 等）
- `scripts/advanced/warp_route_test.sh` - WARP 路由比較工具，測試 WARP VPN 開關前後的效果

## 使用方式

### 執行診斷腳本
```bash
# 基本測試
cd scripts/basic
./20250910-test-github-net.sh

# 完整診斷
cd scripts/advanced  
./github_network_diagnostic_v2.sh

# 影音串流測試
./video_streaming_test.sh

# WARP VPN 效果測試
./warp_route_test.sh
```

### 結果存儲
- 測試結果會存儲在 `results/` 目錄
- `.txt` 和 `.log` 檔案已在 `.gitignore` 中排除

## 技術架構

### 測試目標與方法
所有診斷工具都基於以下核心概念：
- **路由品質測試**：ping 測試延遲和封包遺失率
- **速度測試**：使用 curl 下載測試檔案測量實際速度
- **比較基準**：本地路由器 → 台灣 DNS → 國際服務的遞進測試

### 關鍵測試節點
- `192.168.8.1` - 本地路由器
- `168.95.1.1` - HiNet DNS  
- `8.8.8.8` - Google DNS
- `1.1.1.1` - Cloudflare
- `104.44.32.95` - Microsoft Azure 問題節點
- `github.com`, `gitlab.com` - Git 服務

### WARP VPN 整合
- 使用 `warp-cli status` 檢查 VPN 狀態
- 自動切換 VPN 開關進行前後對比測試
- 支援 IP 位址變更檢測

## 輸出格式
- 使用 ANSI 顏色碼提供視覺化狀態指示
- 綠色：正常連線
- 黃色：不穩定連線  
- 紅色：無法連線
- 藍色：資訊標題

## 開發指引

### 新增診斷工具
1. 在適當的 `scripts/basic/` 或 `scripts/advanced/` 目錄中建立腳本
2. 使用一致的顏色定義和輸出格式
3. 包含時間戳記和狀態檢查
4. 將結果輸出到 `results/` 目錄

### 腳本結構模式
```bash
#!/bin/bash

# 標準顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 標準標題格式
echo "==================================="
echo "   工具名稱 v版本"
echo "==================================="
echo "時間: $(date '+%Y-%m-%d %H:%M:%S')"
```

### 測試目標管理
新增測試目標時使用陣列格式：
```bash
targets=(
    "host:description"
    "example.com:Example"
)
```