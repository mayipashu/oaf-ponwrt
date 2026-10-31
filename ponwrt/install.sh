#!/bin/sh
# One-shot installer for OAF on PonWrt (6.18.55)
# Run as: scp ponwrt/ root@router:/tmp/oaf-ponwrt && ssh root@router 'sh /tmp/oaf-ponwrt/install.sh'
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "=== OAF for PonWrt 安装 ==="

# 1) Load shim
echo "[1/4] 加载 oaf_stub.ko..."
insmod "$DIR/prebuilt/oaf_stub.ko" 2>/dev/null || true
lsmod | grep oaf_stub && echo "  ✓ stub loaded"

# 2) Load oaf.ko (must be pre-patched: vermagic 6.18.34→6.18.55)
if [ -f "$DIR/prebuilt/oaf.ko" ]; then
    echo "[2/4] 加载 oaf.ko..."
    insmod "$DIR/prebuilt/oaf.ko" 2>/dev/null || true
    lsmod | grep "^oaf\b" && echo "  ✓ oaf loaded"
else
    echo "[2/4] ⚠ oaf.ko 未提供（需从 ImmortalWrt kmod-oaf 提取并改 vermagic）"
    echo "  参考 ponwrt/README.md 中 '提取 oaf.ko' 章节"
    exit 1
fi

# 3) Install luci-app-oaf
echo "[3/4] 安装 LuCI 界面..."
apk add --allow-untrusted "$DIR/prebuilt/luci-app-oaf.apk" 2>/dev/null || true
apk add --allow-untrusted "$DIR/prebuilt/luci-i18n-oaf.apk" 2>/dev/null || true

# 4) Extract and install appfilter daemon
echo "[4/4] 安装后台守护进程..."
mkdir -p /tmp/oaf-appfilter
apk extract "$DIR/prebuilt/appfilter.apk" -o /tmp/oaf-appfilter 2>/dev/null || true
cp /tmp/oaf-appfilter/usr/bin/oafd /usr/bin/ 2>/dev/null || true
cp /tmp/oaf-appfilter/usr/bin/oaf_rule /usr/bin/ 2>/dev/null || true
cp /tmp/oaf-appfilter/etc/init.d/appfilter /etc/init.d/ 2>/dev/null || true
chmod +x /usr/bin/oafd /usr/bin/oaf_rule /etc/init.d/appfilter 2>/dev/null || true
rm -rf /tmp/oaf-appfilter

# Persist modules
mkdir -p /lib/modules/$(uname -r)
cp "$DIR/prebuilt/oaf_stub.ko" /lib/modules/$(uname -r)/
cp "$DIR/prebuilt/oaf.ko" /lib/modules/$(uname -r)/
echo -e "oaf_stub\noaf" > /etc/modules.d/oaf

/etc/init.d/appfilter enable
/etc/init.d/appfilter start 2>/dev/null || true

echo
echo "=== 安装完成 ==="
echo "LuCI → 服务 → 家长控制"
echo "lsmod | grep oaf  # verify"
