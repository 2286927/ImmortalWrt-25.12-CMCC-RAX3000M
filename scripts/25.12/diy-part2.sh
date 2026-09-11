#!/bin/bash
#=============================================================
# ImmortalWrt DIY 脚本 2（feeds 更新之后、生成编译配置之前执行）
#  1) 修改默认 LAN IP → 172.16.7.1，设备主机名 → CMCC-RAX3000M
#  2) 从 kenzok8/small-package 导入第三方软件包，并自动与
#     官方（源码树 + feeds）去重：官方已有的一律使用官方版本
#=============================================================

echo "===== diy-part2.sh（25.12）开始执行 ====="
echo "执行时间：$(date '+%Y-%m-%d %H:%M:%S %Z')"

MYDIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# ── 1. 修改 LAN 默认 IP 与主机名 ───────────────────────────────
CONFIG_FILE="package/base-files/files/bin/config_generate"

if [[ -f "$CONFIG_FILE" ]]; then
    # 1a. LAN 默认 IP → 172.16.7.1
    if grep -q "172\.16\.7\.1" "$CONFIG_FILE"; then
        echo "LAN IP 已是 172.16.7.1，无需修改"
    else
        echo "修改 LAN 默认 IP → 172.16.7.1 ..."
        sed -i \
            -e 's/192\.168\.1\.1/172.16.7.1/g' \
            -e 's/192\.168\.2\.1/172.16.7.1/g' \
            -e 's/192\.168\.6\.1/172.16.7.1/g' \
            -e 's/192\.168\.0\.1/172.16.7.1/g' \
            -e 's/192\.168\.100\.1/172.16.7.1/g' \
            "$CONFIG_FILE" 2>/dev/null || echo "  sed 执行出现问题"
    fi

    # 1b. 设备主机名 → CMCC-RAX3000M
    if grep -q "hostname='CMCC-RAX3000M'" "$CONFIG_FILE"; then
        echo "主机名已是 CMCC-RAX3000M，无需修改"
    elif sed -i "s/hostname='ImmortalWrt'/hostname='CMCC-RAX3000M'/" "$CONFIG_FILE" && \
         grep -q "hostname='CMCC-RAX3000M'" "$CONFIG_FILE"; then
        echo "主机名已修改 → CMCC-RAX3000M"
    else
        echo "⚠️  未能定位默认主机名，主机名保持不变"
    fi
else
    echo "⚠️  未找到 config_generate，跳过 IP/主机名修改"
fi

# ── 2. 第三方软件包导入 + 官方自动去重 ─────────────────────────
SYNC_SH="$GITHUB_WORKSPACE/scripts/common/package-sync.sh"
[ -f "$SYNC_SH" ] || SYNC_SH="$MYDIR/../common/package-sync.sh"

if [ -f "$SYNC_SH" ]; then
    bash "$SYNC_SH"
else
    echo "❌ 未找到 package-sync.sh（尝试过 $GITHUB_WORKSPACE/scripts/common/ 与 $MYDIR/../common/）"
    exit 1
fi

echo -e "\n===== diy-part2.sh（25.12）执行结束 ====="
echo ""
