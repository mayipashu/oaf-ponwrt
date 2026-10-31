# Makefile for oaf_stub.ko — shim providing __nf_ct_ext_find on PonWrt
#
# Usage:
#   make KDIR=/path/to/linux-6.18.55 ARCH=arm64 CROSS_COMPILE=aarch64-openwrt-linux-
#
# Or with ImmortalWrt SDK:
#   SDK=toolchain SDK, KDIR=build_dir/target-.../linux-6.18.55
#   make KDIR=$KDIR ARCH=arm64 CROSS_COMPILE=aarch64-openwrt-linux-

obj-m := oaf_stub.o

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

.PHONY: all clean
