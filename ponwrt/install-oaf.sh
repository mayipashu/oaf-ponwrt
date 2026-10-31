#!/bin/sh
# OAF 安装脚本 — PonWrt 6.18.55 定制版
# 前置条件：oaf_stub.ko 和 oaf-patched.ko 已在 /tmp/oaf-build/

set -e

echo "=== 安装 OpenAppFilter (OAF) for PonWrt ==="

# 1) 加载 shim 模块（提供 __nf_ct_ext_find）
echo "[1/5] 加载 oaf_stub.ko..."
insmod /tmp/oaf-build/oaf_stub.ko 2>/dev/null || echo "  (可能已加载)"
lsmod | grep oaf_stub && echo "  ✓ oaf_stub 已加载"

# 2) 加载主模块
echo "[2/5] 加载 oaf.ko..."
mkdir -p /lib/modules/$(uname -r)
cp /tmp/oaf-build/oaf-patched.ko /lib/modules/$(uname -r)/oaf.ko
echo oaf > /etc/modules.d/oaf
insmod /lib/modules/$(uname -r)/oaf.ko 2>/dev/null || echo "  (跳过，可能已加载)"
lsmod | grep oaf && echo "  ✓ oaf 已加载"

# 3) 安装 appfilter（用户空间后台程序）
echo "[3/5] 安装 appfilter..."
cd /tmp/oaf-extract/appfilter
cp -r usr/bin/* /usr/bin/
cp etc/init.d/appfilter /etc/init.d/
cp etc/config/appfilter /etc/config/ 2>/dev/null || true
cp -r etc/appfilter /etc/
echo "  ✓ appfilter 已安装"

# 4) 安装 luci-app-oaf
echo "[4/5] 安装 luci-app-oaf..."
apk add --allow-untrusted /tmp/oaf-build/luci-app-oaf.apk
apk add --allow-untrusted /tmp/oaf-build/luci-i18n-oaf.apk 2>/dev/null || echo "  中文包跳过"
echo "  ✓ luci-app-oaf 已安装"

# 5) 启动 & 验收
echo "[5/5] 启动 appfilter 服务..."
/etc/init.d/appfilter enable
/etc/init.d/appfilter start 2>/dev/null || true
echo
echo "=== 验收 ==="
lsmod | grep oaf && echo "  ✓ oaf 内核模块" || echo "  ✗ oaf 内核模块"
pgrep oafd && echo "  ✓ oafd 守护进程" || echo "  ✗ oafd 守护进程"
echo
echo "安装完成！请在 LuCI → 服务 → OpenAppFilter 中配置。"
