# oaf-ponwrt

[OpenAppFilter](https://github.com/destan19/OpenAppFilter) v7.0.1 的 **PonWrt (airoha/an7581)** 兼容层。

## 做了什么

PonWrt 6.18.55 内核的 `nf_conntrack.ko` 缺少 `__nf_ct_ext_find` 导出——OAF 加载时直接报 `Unknown symbol`。

本仓库提供：
- **`ponwrt/src/oaf_stub.c`** — shim 内核模块（~60 行）
- **`ponwrt/prebuilt/`** — 预编译产物
- **`ponwrt/install.sh`** — 一键安装

## 快速安装

```bash
git clone https://github.com/mayipashu/oaf-ponwrt
scp -r ponwrt/ root@192.168.1.1:/tmp/oaf-ponwrt/
ssh root@192.168.1.1 'sh /tmp/oaf-ponwrt/install.sh'
```

## 原理

```
insmod oaf_stub.ko   → 提供 __nf_ct_ext_find 符号
insmod oaf.ko        → OAF 看到符号已存在，顺利加载
```

## 许可证

PonWrt 兼容层代码 MIT。OAF 原始代码保留 [destan19/OpenAppFilter](https://github.com/destan19/OpenAppFilter) 的许可证。
