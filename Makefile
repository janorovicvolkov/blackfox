# BLACK FOX BASIC CONFIGURATION
SHELL           := /bin/sh
RELEASE_VERSION ?= 1.0.0

# TOOL VERSIONS CONFIGURATION
KERNEL_VERSION        ?= 7.2.3
KERNEL_XZ             ?= 7.2.3
BUSYBOX_VERSION       ?= 1.36.1
E2FSPROGS_VERSION     ?= 1.47.4
DOSFSTOOLS_VERSION    ?= 4.2
LK_VERSION            ?= main
UTIL_LINUX_VERSION    ?= 2.41.2
NTFS3G_VERSION        ?= 2026.7.7
TESTDISK_VERSION      ?= 7.2
RSYNC_VERSION         ?= 3.5.0
XFSPROGS_VERSION      ?= 7.1.1
BTRFSPROGS_VERSION    ?= 7.1
F2FS_TOOLS_VERSION    ?= 1.16.0
DDRESCUE_VERSION      ?= 1.29
SMARTMONTOOLS_VERSION ?= 7.4
MDADM_VERSION         ?= 4.3
GDISK_VERSION         ?= 1.0.10
EXFATPROGS_VERSION    ?= 1.2.9
INIH_VERSION          ?= r58
ZLIB_VERSION          ?= 1.3.1
URCU_VERSION          ?= 0.15.0
NCURSES_VERSION       ?= 6.5
MEMTEST86_VERSION     ?= 8.10
UEFI_SHELL_VERSION    ?= edk2-stable202608

# BUILD DIRECTORIES CONFIGURATION
ROOT_DIR                   := $(shell pwd)
BUILD_DIR                  := $(ROOT_DIR)/build
OUT_DIR                    := $(ROOT_DIR)/out
ROOTFS_DIR                 := $(ROOT_DIR)/rootfs
MEMTEST_BIOS               := $(OUT_DIR)/memtest
MEMTEST_UEFI               := $(OUT_DIR)/memtest.efi
MEMTEST86_ARCHIVE          := mt86plus_$(MEMTEST86_VERSION).src.zip
MEMTEST86_URL              := https://www.memtest.org/download/v$(MEMTEST86_VERSION)/$(MEMTEST86_ARCHIVE)
MEMTEST86_SRC_DIR          := $(BUILD_DIR)/memtest86plus-src
MEMTEST86_BUILD_DIR        := $(MEMTEST86_SRC_DIR)/src/build/x86_64
UEFI_SHELL_SRC_DIR         := $(BUILD_DIR)/edk2-$(UEFI_SHELL_VERSION)
UEFI_SHELL_REPO            := https://github.com/tianocore/edk2.git
UEFI_SHELL_BIN             := $(OUT_DIR)/shellx64.efi
KERNEL_SRC                 := $(BUILD_DIR)/linux-$(KERNEL_XZ)
KERNEL_TAR                 := linux-$(KERNEL_XZ).tar.xz
KERNEL_URL                 := https://www.kernel.org/pub/linux/kernel/v7.x/$(KERNEL_TAR)
KERNEL_IMG                 := $(KERNEL_SRC)/arch/x86/boot/bzImage
BUSYBOX_SRC                := $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)
BUSYBOX_TAR                := busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_URL                := https://busybox.net/downloads/$(BUSYBOX_TAR)
E2FSPROGS_SRC              := $(BUILD_DIR)/e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_TAR              := e2fsprogs-$(E2FSPROGS_VERSION).tar.gz
E2FSPROGS_URL              := https://github.com/tytso/e2fsprogs/archive/refs/tags/v$(E2FSPROGS_VERSION).tar.gz
DOSFSTOOLS_SRC             := $(BUILD_DIR)/dosfstools-$(DOSFSTOOLS_VERSION)
DOSFSTOOLS_TAR             := dosfstools-$(DOSFSTOOLS_VERSION).tar.gz
DOSFSTOOLS_URL             := https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VERSION)/dosfstools-$(DOSFSTOOLS_VERSION).tar.gz
LK_SRC                     := $(BUILD_DIR)/lk-$(LK_VERSION)
LK_REPO                    := https://github.com/source-liskalinux/lk.git
UTIL_LINUX_SRC             := $(BUILD_DIR)/util-linux-$(UTIL_LINUX_VERSION)
UTIL_LINUX_TAR             := util-linux-$(UTIL_LINUX_VERSION).tar.xz
UTIL_LINUX_URL             := https://www.kernel.org/pub/linux/utils/util-linux/v2.41/$(UTIL_LINUX_TAR)
UTIL_LINUX_BINS            := losetup blkid fdisk sfdisk findmnt swapon mkswap blockdev fsck mount umount agetty
UTIL_LINUX_STATIC_PROGRAMS := blkid,fdisk,losetup,sfdisk,mount,umount,agetty
UTIL_LINUX_BINS            += cfdisk
UTIL_LINUX_STATIC_PROGRAMS := $(UTIL_LINUX_STATIC_PROGRAMS),cfdisk
NCURSES_SRC                := $(BUILD_DIR)/ncurses-$(NCURSES_VERSION)
NCURSES_TAR                := ncurses-$(NCURSES_VERSION).tar.gz
NCURSES_URL                := https://invisible-island.net/archives/ncurses/$(NCURSES_TAR)
NCURSES_PREFIX             := $(NCURSES_SRC)/stage
NTFS3G_SRC                 := $(BUILD_DIR)/ntfs-3g-$(NTFS3G_VERSION)
NTFS3G_TAR                 := ntfs-3g-$(NTFS3G_VERSION).tar.gz
NTFS3G_URL                 := https://github.com/tuxera/ntfs-3g/archive/$(NTFS3G_VERSION)/$(NTFS3G_TAR)
TESTDISK_SRC               := $(BUILD_DIR)/testdisk-$(TESTDISK_VERSION)
TESTDISK_TAR               := testdisk-$(TESTDISK_VERSION).tar.bz2
TESTDISK_URL               := https://www.cgsecurity.org/$(TESTDISK_TAR)
RSYNC_SRC                  := $(BUILD_DIR)/rsync-$(RSYNC_VERSION)
RSYNC_TAR                  := rsync-$(RSYNC_VERSION).tar.gz
RSYNC_URL                  := https://rsync.samba.org/ftp/rsync/src/$(RSYNC_TAR)
XFSPROGS_SRC               := $(BUILD_DIR)/xfsprogs-$(XFSPROGS_VERSION)
XFSPROGS_TAR               := xfsprogs-$(XFSPROGS_VERSION).tar.xz
XFSPROGS_URL               := https://www.kernel.org/pub/linux/utils/fs/xfs/xfsprogs/$(XFSPROGS_TAR)
BTRFSPROGS_SRC             := $(BUILD_DIR)/btrfs-progs-$(BTRFSPROGS_VERSION)
BTRFSPROGS_TAR             := btrfs-progs-$(BTRFSPROGS_VERSION).tar.gz
BTRFSPROGS_URL             := https://github.com/kdave/btrfs-progs/archive/refs/tags/v$(BTRFSPROGS_VERSION).tar.gz
F2FS_TOOLS_SRC             := $(BUILD_DIR)/f2fs-tools-$(F2FS_TOOLS_VERSION)
F2FS_TOOLS_TAR             := f2fs-tools-$(F2FS_TOOLS_VERSION).tar.gz
F2FS_TOOLS_URL             := https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/f2fs-tools-$(F2FS_TOOLS_VERSION).tar.gz
DDRESCUE_SRC               := $(BUILD_DIR)/ddrescue-$(DDRESCUE_VERSION)
DDRESCUE_TAR               := ddrescue-$(DDRESCUE_VERSION).tar.lz
DDRESCUE_URL               := https://ftp.gnu.org/gnu/ddrescue/$(DDRESCUE_TAR)
SMARTMONTOOLS_SRC          := $(BUILD_DIR)/smartmontools-$(SMARTMONTOOLS_VERSION)
SMARTMONTOOLS_TAR          := smartmontools-$(SMARTMONTOOLS_VERSION).tar.gz
SMARTMONTOOLS_URL          := https://github.com/smartmontools/smartmontools/releases/download/RELEASE_$(subst .,_,$(SMARTMONTOOLS_VERSION))/$(SMARTMONTOOLS_TAR)
MDADM_SRC                  := $(BUILD_DIR)/mdadm-$(MDADM_VERSION)
MDADM_TAR                  := mdadm-$(MDADM_VERSION).tar.xz
MDADM_URL                  := https://www.kernel.org/pub/linux/utils/raid/mdadm/$(MDADM_TAR)
GDISK_SRC                  := $(BUILD_DIR)/gptfdisk-$(GDISK_VERSION)
GDISK_TAR                  := gptfdisk-$(GDISK_VERSION).tar.gz
GDISK_URL                  := https://sourceforge.net/projects/gptfdisk/files/gptfdisk/$(GDISK_VERSION)/$(GDISK_TAR)/download
EXFATPROGS_SRC             := $(BUILD_DIR)/exfatprogs-$(EXFATPROGS_VERSION)
EXFATPROGS_TAR             := exfatprogs-$(EXFATPROGS_VERSION).tar.xz
EXFATPROGS_URL             := https://github.com/exfatprogs/exfatprogs/releases/download/$(EXFATPROGS_VERSION)/$(EXFATPROGS_TAR)
INIH_SRC                   := $(BUILD_DIR)/inih-$(INIH_VERSION)
INIH_TAR                   := inih-$(INIH_VERSION).tar.gz
INIH_URL                   := https://github.com/benhoyt/inih/archive/refs/tags/$(INIH_VERSION).tar.gz
ZLIB_SRC                   := $(BUILD_DIR)/zlib-$(ZLIB_VERSION)
ZLIB_TAR                   := zlib-$(ZLIB_VERSION).tar.gz
ZLIB_URL                   := https://github.com/madler/zlib/archive/refs/tags/v$(ZLIB_VERSION).tar.gz
URCU_SRC                   := $(BUILD_DIR)/userspace-rcu-$(URCU_VERSION)
URCU_TAR                   := userspace-rcu-$(URCU_VERSION).tar.gz
URCU_URL                   := https://github.com/urcu/userspace-rcu/archive/refs/tags/v$(URCU_VERSION).tar.gz
INIT_TARGET                := x86_64-unknown-linux-musl
INIT_BIN                   := $(ROOT_DIR)/target/$(INIT_TARGET)/release/init
FOX_BIN                    := $(ROOT_DIR)/target/$(INIT_TARGET)/release/fox
POWER_BIN                  := $(ROOT_DIR)/target/$(INIT_TARGET)/release/power

# OUTPUT FILES CONFIGURATION
IMAGE_NAME      ?= blackfox
KERNEL_OUT      := $(OUT_DIR)/$(IMAGE_NAME)
IMG_OUT         := $(OUT_DIR)/$(IMAGE_NAME).img
ISO_OUT         := $(OUT_DIR)/$(IMAGE_NAME).iso
RELEASE_TAG     ?= v$(RELEASE_VERSION)
RELEASE_DIR     := $(OUT_DIR)/release
RELEASE_ARCHIVE := $(RELEASE_DIR)/$(IMAGE_NAME)-$(RELEASE_TAG)-x86_64.tar.zst
RELEASE_ISO     := $(RELEASE_DIR)/$(IMAGE_NAME)-$(RELEASE_TAG)-x86_64.iso
RELEASE_SUM     := $(RELEASE_DIR)/$(IMAGE_NAME)-$(RELEASE_TAG)-x86_64.tar.zst.sha256
RELEASE_SUM_ISO := $(RELEASE_DIR)/$(IMAGE_NAME)-$(RELEASE_TAG)-x86_64.iso.sha256
NPROC := $(shell nproc)

.PHONY: all kernel busybox init fox-tool power-tool memtest uefi-shell tools lk-tool ncurses-tool util-linux-tool ntfs3g-tool testdisk-tool rsync-tool xfsprogs-tool btrfs-progs-tool f2fs-tools-tool ddrescue-tool smartmontools-tool mdadm-tool gdisk-tool exfatprogs-tool inih-tool zlib-tool urcu-tool rootfs iso run iso-test test release github-release clean cleanall help

all: rootfs kernel


# KERNEL BUILD
kernel:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(KERNEL_TAR) $(KERNEL_URL)
	tar xf $(BUILD_DIR)/$(KERNEL_TAR) -C $(BUILD_DIR)
	cd $(KERNEL_SRC) && \
		make tinyconfig && \
		$(KERNEL_SRC)/scripts/kconfig/merge_config.sh -O $(KERNEL_SRC) $(KERNEL_SRC)/.config $(ROOT_DIR)/configs/kernel.config && \
			make olddefconfig && \
		make -j$(NPROC) bzImage
	mkdir -p $(OUT_DIR)
	cp $(KERNEL_IMG) $(KERNEL_OUT)


# BUSYBOX BUILD
busybox:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(BUSYBOX_TAR) $(BUSYBOX_URL)
	tar xf $(BUILD_DIR)/$(BUSYBOX_TAR) -C $(BUILD_DIR)
	cd $(BUSYBOX_SRC) && make defconfig
	sed -i 's|CONFIG_TC=y|# CONFIG_TC is not set|g' $(BUSYBOX_SRC)/.config
	sed -i 's|# CONFIG_STATIC is not set|CONFIG_STATIC=y|g' $(BUSYBOX_SRC)/.config
	for cfg in CONFIG_CP CONFIG_MV CONFIG_RM CONFIG_MKDIR CONFIG_CHMOD CONFIG_CHOWN CONFIG_LN \
	           CONFIG_MOUNT CONFIG_UMOUNT CONFIG_LOSETUP CONFIG_BLKID CONFIG_LSBLK CONFIG_ADDUSER \
	           CONFIG_FDISK CONFIG_SFDISK CONFIG_FINDMNT CONFIG_SWAPON CONFIG_SWAPOFF CONFIG_SU \
	           CONFIG_MKSWAP CONFIG_BLOCKDEV CONFIG_FSCK CONFIG_WHICH CONFIG_DELUSER \
			   CONFIG_PASSWD CONFIG_LOGIN CONFIG_ADDGROUP CONFIG_DELGROUP CONFIG_CHPASSWD \
			   CONFIG_ID CONFIG_WHOAMI CONFIG_SULOGIN CONFIG_VLOCK CONFIG_INIT CONFIG_GETTY \
			   CONFIG_CTTYHACK CONFIG_RMDIR CONFIG_RMMOD CONFIG_STTY CONFIG_HOSTNAME CONFIG_UNAME \
			   CONFIG_USERS CONFIG_TTY CONFIG_RUN_INIT CONFIG_ADD_SHELL CONFIG_MKPASSWD CONFIG_REMOVE_SHELL \
			   CONFIG_MKE2FS CONFIG_MKDOSFS CONFIG_MKFS_EXT2 CONFIG_MKFS_VFAT CONFIG_SWITCH_ROOT \
			   CONFIG_REBOOT CONFIG_POWEROFF; do \
		sed -i "s|$${cfg}=y|# $${cfg} is not set|g" $(BUSYBOX_SRC)/.config; \
	done
	$(MAKE) -C $(BUSYBOX_SRC) -j$(NPROC)
	mkdir -p $(OUT_DIR)
	cp $(BUSYBOX_SRC)/busybox $(OUT_DIR)/busybox

# INIT BUILD
init:
	rustup target add $(INIT_TARGET) 2>/dev/null || true
	cargo build --release --target $(INIT_TARGET)
	mkdir -p $(OUT_DIR)
	cp $(INIT_BIN) $(OUT_DIR)/init
	chmod +x $(OUT_DIR)/init

# FOX TOOL BUILD
fox-tool:
	rustup target add $(INIT_TARGET) 2>/dev/null || true
	cargo build --release --target $(INIT_TARGET) --bin fox
	mkdir -p $(OUT_DIR)/tools
	cp $(FOX_BIN) $(OUT_DIR)/tools/fox
	strip $(OUT_DIR)/tools/fox 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/fox

# POWER COMMAND BUILD
power-tool:
	rustup target add $(INIT_TARGET) 2>/dev/null || true
	cargo build --release --target $(INIT_TARGET) --bin power
	mkdir -p $(OUT_DIR)/tools
	cp $(POWER_BIN) $(OUT_DIR)/tools/poweroff
	cp $(POWER_BIN) $(OUT_DIR)/tools/reboot
	strip $(OUT_DIR)/tools/poweroff $(OUT_DIR)/tools/reboot 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/poweroff $(OUT_DIR)/tools/reboot


# MEMTEST BUILD
memtest:
	mkdir -p $(BUILD_DIR)
	if [ ! -f $(MEMTEST86_BUILD_DIR)/mt86plus ]; then \
		wget -O $(BUILD_DIR)/$(MEMTEST86_ARCHIVE) $(MEMTEST86_URL); \
		rm -rf $(MEMTEST86_SRC_DIR); \
		mkdir -p $(MEMTEST86_SRC_DIR); \
		unzip -q $(BUILD_DIR)/$(MEMTEST86_ARCHIVE) -d $(MEMTEST86_SRC_DIR); \
	fi
	cd $(MEMTEST86_BUILD_DIR) && $(MAKE) mt86plus
	cp $(MEMTEST86_BUILD_DIR)/mt86plus $(MEMTEST_BIOS)
	cp $(MEMTEST86_BUILD_DIR)/mt86plus $(MEMTEST_UEFI)
	@file $(MEMTEST_BIOS) $(MEMTEST_UEFI)


# UEFI SHELL BUILD
uefi-shell:
	mkdir -p $(BUILD_DIR)
	if [ ! -f $(UEFI_SHELL_SRC_DIR)/BaseTools/Source/C/BrotliCompress/brotli/c/common/constants.h ]; then \
		rm -rf $(UEFI_SHELL_SRC_DIR); \
		git clone --depth 1 --branch $(UEFI_SHELL_VERSION) --recurse-submodules --shallow-submodules $(UEFI_SHELL_REPO) $(UEFI_SHELL_SRC_DIR); \
	fi
	git -C $(UEFI_SHELL_SRC_DIR) submodule update --init --recursive BaseTools/Source/C/BrotliCompress/brotli
	$(MAKE) -C $(UEFI_SHELL_SRC_DIR)/BaseTools -j$(NPROC)
	mkdir -p $(UEFI_SHELL_SRC_DIR)/MdePkg/Library/MipiSysTLib/mipisyst/library/include
	cd $(UEFI_SHELL_SRC_DIR) && . ./edksetup.sh && build -a X64 -t GCC -b RELEASE -p ShellPkg/ShellPkg.dsc
	mkdir -p $(OUT_DIR)
	cp $(UEFI_SHELL_SRC_DIR)/Build/Shell/RELEASE_GCC/X64/ShellPkg/Application/Shell/Shell/DEBUG/Shell.efi $(UEFI_SHELL_BIN)
	@file $(UEFI_SHELL_BIN)


# TOOLS BUILD
tools: e2fsprogs-tool dosfstools-tool fox-tool power-tool lk-tool util-linux-tool ntfs3g-tool testdisk-tool rsync-tool xfsprogs-tool btrfs-progs-tool f2fs-tools-tool ddrescue-tool smartmontools-tool mdadm-tool gdisk-tool exfatprogs-tool
	file $(OUT_DIR)/tools/*

e2fsprogs-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(E2FSPROGS_TAR) $(E2FSPROGS_URL)
	tar xf $(BUILD_DIR)/$(E2FSPROGS_TAR) -C $(BUILD_DIR)
	cd $(E2FSPROGS_SRC) && ./configure --enable-elf-shlibs=no --disable-nls --disable-fuse2fs \
		CFLAGS="-static" LDFLAGS="-static"
	$(MAKE) -C $(E2FSPROGS_SRC) -j$(NPROC)
	mkdir -p $(OUT_DIR)/tools
	cp $(E2FSPROGS_SRC)/e2fsck/e2fsck    $(OUT_DIR)/tools/e2fsck
	cp $(E2FSPROGS_SRC)/e2fsck/e2fsck    $(OUT_DIR)/tools/fsck.ext4
	cp $(E2FSPROGS_SRC)/resize/resize2fs $(OUT_DIR)/tools/resize2fs
	cp $(E2FSPROGS_SRC)/misc/mke2fs      $(OUT_DIR)/tools/mke2fs
	cp $(E2FSPROGS_SRC)/misc/mke2fs      $(OUT_DIR)/tools/mkfs.ext4
	cp $(E2FSPROGS_SRC)/misc/dumpe2fs    $(OUT_DIR)/tools/dumpe2fs
	cp $(E2FSPROGS_SRC)/misc/tune2fs     $(OUT_DIR)/tools/tune2fs
	strip $(OUT_DIR)/tools/* 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/*

dosfstools-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(DOSFSTOOLS_TAR) $(DOSFSTOOLS_URL)
	tar xf $(BUILD_DIR)/$(DOSFSTOOLS_TAR) -C $(BUILD_DIR)
	cd $(DOSFSTOOLS_SRC) && ./configure --enable-static \
		CFLAGS="-static" LDFLAGS="-static"
	$(MAKE) -C $(DOSFSTOOLS_SRC) -j$(NPROC)
	mkdir -p $(OUT_DIR)/tools
	cp $(DOSFSTOOLS_SRC)/src/fsck.fat $(OUT_DIR)/tools/fsck.vfat
	cp $(DOSFSTOOLS_SRC)/src/fsck.fat $(OUT_DIR)/tools/fsck.fat
	cp $(DOSFSTOOLS_SRC)/src/mkfs.fat $(OUT_DIR)/tools/mkfs.vfat
	cp $(DOSFSTOOLS_SRC)/src/mkfs.fat $(OUT_DIR)/tools/mkfs.fat
	strip $(OUT_DIR)/tools/* 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/*

ddrescue-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(DDRESCUE_TAR) $(DDRESCUE_URL)
	tar xf $(BUILD_DIR)/$(DDRESCUE_TAR) -C $(BUILD_DIR)
	cd $(DDRESCUE_SRC) && ./configure CXX=g++ CXXFLAGS="-O2 -static-libstdc++ -static-libgcc" LDFLAGS="-static"
	$(MAKE) -C $(DDRESCUE_SRC) -j$(NPROC) CXX=g++ CXXFLAGS="-O2 -static-libstdc++ -static-libgcc" LDFLAGS="-static"
	mkdir -p $(OUT_DIR)/tools
	cp $(DDRESCUE_SRC)/ddrescue $(OUT_DIR)/tools/ddrescue
	strip $(OUT_DIR)/tools/ddrescue 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/ddrescue

smartmontools-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(SMARTMONTOOLS_TAR) $(SMARTMONTOOLS_URL)
	tar xf $(BUILD_DIR)/$(SMARTMONTOOLS_TAR) -C $(BUILD_DIR)
	cd $(SMARTMONTOOLS_SRC) && ./configure --disable-shared --enable-static --without-update-smart-drivedb \
		CXX=g++ CXXFLAGS="-O2 -static-libstdc++ -static-libgcc" LDFLAGS="-static"
	$(MAKE) -C $(SMARTMONTOOLS_SRC) -j$(NPROC) CXX=g++ CXXFLAGS="-O2 -static-libstdc++ -static-libgcc" LDFLAGS="-static"
	mkdir -p $(OUT_DIR)/tools
	cp $(SMARTMONTOOLS_SRC)/smartctl $(OUT_DIR)/tools/smartctl
	strip $(OUT_DIR)/tools/smartctl 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/smartctl

mdadm-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(MDADM_TAR) $(MDADM_URL)
	tar xf $(BUILD_DIR)/$(MDADM_TAR) -C $(BUILD_DIR)
	sed -i 's|#include[[:space:]]*<libudev.h>|#ifndef NO_LIBUDEV\n#include <libudev.h>\n#endif|' $(MDADM_SRC)/udev.c
	$(MAKE) -C $(MDADM_SRC) -j$(NPROC) CC=musl-gcc CWFLAGS= \
		CXFLAGS="-O2 -static -D_LARGEFILE64_SOURCE -DNO_COROSYNC -DNO_DLM -DNO_LIBUDEV -include limits.h -include libgen.h -include linux/falloc.h" \
		LDFLAGS="-static" LDLIBS="-ldl" mdadm.static
	mkdir -p $(OUT_DIR)/tools
	cp $(MDADM_SRC)/mdadm.static $(OUT_DIR)/tools/mdadm
	strip $(OUT_DIR)/tools/mdadm 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/mdadm

gdisk-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(GDISK_TAR) $(GDISK_URL)
	tar xf $(BUILD_DIR)/$(GDISK_TAR) -C $(BUILD_DIR)
	$(MAKE) -C $(GDISK_SRC) -j$(NPROC) TARGET=linux CXX=g++ \
		CXXFLAGS="-O2 -static-libstdc++ -static-libgcc -D_FILE_OFFSET_BITS=64" \
		LDFLAGS="-static -L$(UTIL_LINUX_SRC)/.libs" sgdisk
	mkdir -p $(OUT_DIR)/tools
	cp $(GDISK_SRC)/sgdisk $(OUT_DIR)/tools/sgdisk
	strip $(OUT_DIR)/tools/sgdisk 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/sgdisk

exfatprogs-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(EXFATPROGS_TAR) $(EXFATPROGS_URL)
	tar xf $(BUILD_DIR)/$(EXFATPROGS_TAR) -C $(BUILD_DIR)
	cd $(EXFATPROGS_SRC) && CC=musl-gcc ./configure --disable-shared --enable-static \
		CFLAGS="-O2 -fno-pie" LDFLAGS="-static -no-pie"
	$(MAKE) -C $(EXFATPROGS_SRC) clean 2>/dev/null || true
	$(MAKE) -C $(EXFATPROGS_SRC) -j$(NPROC) CC=musl-gcc CFLAGS="-O2 -fno-pie" \
		LDFLAGS="-all-static -static -no-pie"
	mkdir -p $(OUT_DIR)/tools
	cp $(EXFATPROGS_SRC)/mkfs/mkfs.exfat $(OUT_DIR)/tools/mkfs.exfat
	cp $(EXFATPROGS_SRC)/fsck/fsck.exfat $(OUT_DIR)/tools/fsck.exfat
	cp $(EXFATPROGS_SRC)/dump/dump.exfat $(OUT_DIR)/tools/dump.exfat
	strip $(OUT_DIR)/tools/mkfs.exfat $(OUT_DIR)/tools/fsck.exfat $(OUT_DIR)/tools/dump.exfat 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/mkfs.exfat $(OUT_DIR)/tools/fsck.exfat $(OUT_DIR)/tools/dump.exfat

lk-tool:
	mkdir -p $(BUILD_DIR)
	rm -rf $(LK_SRC)
	git clone --branch $(LK_VERSION) --depth 1 $(LK_REPO) $(LK_SRC)
	rustup target add $(INIT_TARGET) 2>/dev/null || true
	cd $(LK_SRC) && cargo build --release --target $(INIT_TARGET) -p lk
	mkdir -p $(OUT_DIR)/tools
	cp $(LK_SRC)/target/$(INIT_TARGET)/release/lk $(OUT_DIR)/tools/lk
	strip $(OUT_DIR)/tools/lk 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/lk

ncurses-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(NCURSES_TAR) $(NCURSES_URL)
	rm -rf $(NCURSES_SRC)
	tar xf $(BUILD_DIR)/$(NCURSES_TAR) -C $(BUILD_DIR)
	cd $(NCURSES_SRC) && CC=musl-gcc ./configure --prefix=$(NCURSES_PREFIX) \
		--enable-widec --without-shared --with-normal --without-debug \
		--without-cxx --without-cxx-binding --without-progs --without-manpages \
		--without-tests --without-ada --disable-stripping CFLAGS="-O2"
	$(MAKE) -C $(NCURSES_SRC) -j$(NPROC) CC=musl-gcc
	$(MAKE) -C $(NCURSES_SRC) install.libs install.includes

util-linux-tool: ncurses-tool
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(UTIL_LINUX_TAR) $(UTIL_LINUX_URL)
	tar xf $(BUILD_DIR)/$(UTIL_LINUX_TAR) -C $(BUILD_DIR)
	cd $(UTIL_LINUX_SRC) && CC=musl-gcc ./configure --enable-static --disable-shared --disable-liblastlog2 \
		--without-python --disable-pylibmount --with-ncursesw \
		--without-systemd --without-udev --disable-chfn-chsh --disable-login \
		--disable-nologin --disable-su --disable-runuser \
		--disable-setpriv --disable-rfkill --disable-lsblk \
		--enable-static-programs=$(UTIL_LINUX_STATIC_PROGRAMS) \
		CFLAGS="-static -I$(NCURSES_PREFIX)/include" \
		LDFLAGS="-static -L$(NCURSES_PREFIX)/lib" \
		TINFO_LIBS="-L$(NCURSES_PREFIX)/lib -lncursesw" \
		TINFO_LIBS_STATIC="-L$(NCURSES_PREFIX)/lib -lncursesw"
	$(MAKE) -C $(UTIL_LINUX_SRC) CC=musl-gcc LDFLAGS="-static" libtcolors.la
	sed -i "s/dependency_libs=' -lncursesw'/dependency_libs=''/" \
		$(UTIL_LINUX_SRC)/libtcolors.la
	$(MAKE) -C $(UTIL_LINUX_SRC) -j$(NPROC) CC=musl-gcc LDFLAGS="-static -all-static" \
		TINFO_LIBS= TINFO_LIBS_STATIC= $(UTIL_LINUX_BINS)
	mkdir -p $(OUT_DIR)/tools
	for b in $(UTIL_LINUX_BINS); do \
		cp $(UTIL_LINUX_SRC)/$$b $(OUT_DIR)/tools/$$b; \
	done
	cp $(OUT_DIR)/tools/swapon $(OUT_DIR)/tools/swapoff
	strip $(addprefix $(OUT_DIR)/tools/,$(UTIL_LINUX_BINS)) $(OUT_DIR)/tools/swapoff 2>/dev/null || true
	chmod +x $(addprefix $(OUT_DIR)/tools/,$(UTIL_LINUX_BINS)) $(OUT_DIR)/tools/swapoff

ntfs3g-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(NTFS3G_TAR) $(NTFS3G_URL)
	tar xf $(BUILD_DIR)/$(NTFS3G_TAR) -C $(BUILD_DIR)
	cd $(NTFS3G_SRC) && ./autogen.sh && CC=musl-gcc ./configure --enable-static --disable-shared \
		--with-fuse=internal --disable-plugins \
		CFLAGS="-static" LDFLAGS="-static"
	$(MAKE) -C $(NTFS3G_SRC) -j$(NPROC) CC=musl-gcc LDFLAGS="-static -all-static"
	mkdir -p $(OUT_DIR)/tools
	cp $(NTFS3G_SRC)/src/ntfs-3g            $(OUT_DIR)/tools/ntfs-3g
	cp $(NTFS3G_SRC)/src/ntfs-3g            $(OUT_DIR)/tools/mount.ntfs
	cp $(NTFS3G_SRC)/src/ntfs-3g            $(OUT_DIR)/tools/mount.ntfs-3g
	cp $(NTFS3G_SRC)/ntfsprogs/ntfsfix      $(OUT_DIR)/tools/ntfsfix
	cp $(NTFS3G_SRC)/ntfsprogs/ntfsresize   $(OUT_DIR)/tools/ntfsresize
	cp $(NTFS3G_SRC)/ntfsprogs/ntfsclone    $(OUT_DIR)/tools/ntfsclone
	cp $(NTFS3G_SRC)/ntfsprogs/ntfslabel    $(OUT_DIR)/tools/ntfslabel
	cp $(NTFS3G_SRC)/ntfsprogs/mkntfs       $(OUT_DIR)/tools/mkntfs
	cp $(NTFS3G_SRC)/ntfsprogs/mkntfs       $(OUT_DIR)/tools/mkfs.ntfs
	strip $(OUT_DIR)/tools/ntfs-3g $(OUT_DIR)/tools/mount.ntfs $(OUT_DIR)/tools/mount.ntfs-3g \
		$(OUT_DIR)/tools/ntfsfix $(OUT_DIR)/tools/ntfsresize $(OUT_DIR)/tools/ntfsclone \
		$(OUT_DIR)/tools/ntfslabel $(OUT_DIR)/tools/mkntfs $(OUT_DIR)/tools/mkfs.ntfs 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/ntfs-3g $(OUT_DIR)/tools/mount.ntfs $(OUT_DIR)/tools/mount.ntfs-3g \
		$(OUT_DIR)/tools/ntfsfix $(OUT_DIR)/tools/ntfsresize $(OUT_DIR)/tools/ntfsclone \
		$(OUT_DIR)/tools/ntfslabel $(OUT_DIR)/tools/mkntfs $(OUT_DIR)/tools/mkfs.ntfs

testdisk-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(TESTDISK_TAR) $(TESTDISK_URL)
	tar xf $(BUILD_DIR)/$(TESTDISK_TAR) -C $(BUILD_DIR)
	sed -i 's/td_getcwd(\&dst_path,/td_getcwd(dst_path,/' \
		$(TESTDISK_SRC)/src/adv.c
	cd $(TESTDISK_SRC) && ./configure --without-ntfs3g --without-ext2fs \
		--without-ncurses --without-zlib --without-jpeg
	$(MAKE) -C $(TESTDISK_SRC) -j$(NPROC) static
	mkdir -p $(OUT_DIR)/tools
	cp $(TESTDISK_SRC)/src/testdisk $(OUT_DIR)/tools/testdisk
	cp $(TESTDISK_SRC)/src/photorec $(OUT_DIR)/tools/photorec
	strip $(OUT_DIR)/tools/testdisk $(OUT_DIR)/tools/photorec 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/testdisk $(OUT_DIR)/tools/photorec

rsync-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(RSYNC_TAR) $(RSYNC_URL)
	tar xf $(BUILD_DIR)/$(RSYNC_TAR) -C $(BUILD_DIR)
	cd $(RSYNC_SRC) && ./configure --disable-openssl --disable-lz4 --disable-xxhash --disable-zstd \
		CFLAGS="-static" LDFLAGS="-static"
	$(MAKE) -C $(RSYNC_SRC) -j$(NPROC)
	mkdir -p $(OUT_DIR)/tools
	cp $(RSYNC_SRC)/rsync $(OUT_DIR)/tools/rsync
	strip $(OUT_DIR)/tools/rsync 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/rsync

xfsprogs-tool: inih-tool util-linux-tool urcu-tool
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(XFSPROGS_TAR) $(XFSPROGS_URL)
	rm -rf $(XFSPROGS_SRC)
	tar xf $(BUILD_DIR)/$(XFSPROGS_TAR) -C $(BUILD_DIR)
	cd $(XFSPROGS_SRC) && PKG_CONFIG=false CC=gcc ./configure --enable-static --disable-shared --disable-libicu \
		--disable-xfs_scrub --disable-xfs_fsr --disable-docs \
		CPPFLAGS="-I$(INIH_SRC) -I$(URCU_SRC)/include" \
		LDFLAGS="-L$(INIH_SRC) -L$(UTIL_LINUX_SRC)/.libs -L$(URCU_SRC)/src/.libs -static"
	$(MAKE) -C $(XFSPROGS_SRC) -j$(NPROC) CC=gcc \
		LDFLAGS="-L$(INIH_SRC) -L$(UTIL_LINUX_SRC)/.libs -L$(URCU_SRC)/src/.libs -static -all-static"
	mkdir -p $(OUT_DIR)/tools
	cp $(XFSPROGS_SRC)/db/xfs_db $(OUT_DIR)/tools/xfs_db
	cp $(XFSPROGS_SRC)/db/xfs_admin.sh $(OUT_DIR)/tools/xfs_admin
	cp $(XFSPROGS_SRC)/growfs/xfs_growfs $(OUT_DIR)/tools/xfs_growfs
	cp $(XFSPROGS_SRC)/spaceman/xfs_info.sh $(OUT_DIR)/tools/xfs_info
	cp $(XFSPROGS_SRC)/mkfs/mkfs.xfs $(OUT_DIR)/tools/mkfs.xfs
	cp $(XFSPROGS_SRC)/repair/xfs_repair $(OUT_DIR)/tools/xfs_repair
	strip $(OUT_DIR)/tools/mkfs.xfs $(OUT_DIR)/tools/xfs_* 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/mkfs.xfs $(OUT_DIR)/tools/xfs_*

btrfs-progs-tool: zlib-tool
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(BTRFSPROGS_TAR) $(BTRFSPROGS_URL)
	rm -rf $(BTRFSPROGS_SRC)
	tar xf $(BUILD_DIR)/$(BTRFSPROGS_TAR) -C $(BUILD_DIR)
	mkdir -p $(BTRFSPROGS_SRC)/include/uuid
	cp $(UTIL_LINUX_SRC)/libuuid/src/uuid.h $(BTRFSPROGS_SRC)/include/uuid/uuid.h
	mkdir -p $(BTRFSPROGS_SRC)/include/blkid
	cp $(UTIL_LINUX_SRC)/libblkid/src/blkid.h $(BTRFSPROGS_SRC)/include/blkid/blkid.h
	cp $(ZLIB_SRC)/zlib.h $(BTRFSPROGS_SRC)/include/zlib.h
	cp $(ZLIB_SRC)/zconf.h $(BTRFSPROGS_SRC)/include/zconf.h
	cd $(BTRFSPROGS_SRC) && ./autogen.sh && CC=musl-gcc ./configure --enable-static --disable-shared --disable-documentation \
		--disable-python --disable-libudev --disable-backtrace --disable-zstd --disable-lzo \
		CFLAGS="-static -I$(BTRFSPROGS_SRC)/include" \
		LDFLAGS="-L$(BUILD_DIR)/util-linux-$(UTIL_LINUX_VERSION)/.libs -L$(ZLIB_SRC) -static"
	$(MAKE) -C $(BTRFSPROGS_SRC) -j$(NPROC) CC=musl-gcc \
		CPPFLAGS="-I$(BTRFSPROGS_SRC)/include" \
		LDFLAGS="-L$(BUILD_DIR)/util-linux-$(UTIL_LINUX_VERSION)/.libs -L$(ZLIB_SRC) -static" btrfs mkfs.btrfs
	mkdir -p $(OUT_DIR)/tools
	cp $(BTRFSPROGS_SRC)/btrfs $(OUT_DIR)/tools/btrfs
	cp $(BTRFSPROGS_SRC)/mkfs.btrfs $(OUT_DIR)/tools/mkfs.btrfs
	cp $(BTRFSPROGS_SRC)/fsck.btrfs $(OUT_DIR)/tools/fsck.btrfs
	strip $(OUT_DIR)/tools/btrfs $(OUT_DIR)/tools/mkfs.btrfs 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/btrfs $(OUT_DIR)/tools/mkfs.btrfs $(OUT_DIR)/tools/fsck.btrfs

f2fs-tools-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(F2FS_TOOLS_TAR) $(F2FS_TOOLS_URL)
	rm -rf $(F2FS_TOOLS_SRC)
	tar xf $(BUILD_DIR)/$(F2FS_TOOLS_TAR) -C $(BUILD_DIR)
	sed -i '/#include <sys\/stat.h>/a #include <sys\/sysmacros.h>' $(F2FS_TOOLS_SRC)/lib/libf2fs.c
	sed -i 's/typedef u8[[:space:]]*bool;/typedef u8 f2fs_legacy_bool;/' $(F2FS_TOOLS_SRC)/include/f2fs_fs.h
	cd $(F2FS_TOOLS_SRC) && ./autogen.sh && CC=musl-gcc ./configure --enable-static --disable-shared \
		--without-selinux --without-crypto CFLAGS="-static -DHAVE_LSEEK64" \
		LDFLAGS="-static"
	$(MAKE) -C $(F2FS_TOOLS_SRC)/lib -j$(NPROC) CC=musl-gcc \
		CFLAGS="-static -DHAVE_LSEEK64" LDFLAGS="-static -all-static"
	$(MAKE) -C $(F2FS_TOOLS_SRC)/mkfs -j$(NPROC) CC=musl-gcc \
		CFLAGS="-static -DHAVE_LSEEK64" LDFLAGS="-static -all-static"
	$(MAKE) -C $(F2FS_TOOLS_SRC)/fsck -j$(NPROC) CC=musl-gcc \
		CFLAGS="-static -DHAVE_LSEEK64" LDFLAGS="-static -all-static"
	mkdir -p $(OUT_DIR)/tools
	cp $(F2FS_TOOLS_SRC)/mkfs/mkfs.f2fs $(OUT_DIR)/tools/mkfs.f2fs
	cp $(F2FS_TOOLS_SRC)/fsck/fsck.f2fs $(OUT_DIR)/tools/fsck.f2fs
	cp $(F2FS_TOOLS_SRC)/fsck/fsck.f2fs $(OUT_DIR)/tools/dump.f2fs
	cp $(F2FS_TOOLS_SRC)/fsck/fsck.f2fs $(OUT_DIR)/tools/resize.f2fs
	cp $(F2FS_TOOLS_SRC)/fsck/fsck.f2fs $(OUT_DIR)/tools/sload.f2fs
	strip $(OUT_DIR)/tools/mkfs.f2fs $(OUT_DIR)/tools/fsck.f2fs $(OUT_DIR)/tools/dump.f2fs \
		$(OUT_DIR)/tools/resize.f2fs $(OUT_DIR)/tools/sload.f2fs 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/mkfs.f2fs $(OUT_DIR)/tools/fsck.f2fs $(OUT_DIR)/tools/dump.f2fs \
		$(OUT_DIR)/tools/resize.f2fs $(OUT_DIR)/tools/sload.f2fs

inih-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(INIH_TAR) $(INIH_URL)
	tar xf $(BUILD_DIR)/$(INIH_TAR) -C $(BUILD_DIR)
	musl-gcc -c -O2 -fPIC $(INIH_SRC)/ini.c -o $(INIH_SRC)/ini.o
	ar rcs $(INIH_SRC)/libinih.a $(INIH_SRC)/ini.o
	mkdir -p $(INIH_SRC)/uuid
	printf '%s\n' '#ifndef UUID_UUID_H' '#define UUID_UUID_H' 'typedef unsigned char uuid_t[16];' \
		'int uuid_compare(const uuid_t a, const uuid_t b);' '#endif' > $(INIH_SRC)/uuid/uuid.h

zlib-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(ZLIB_TAR) $(ZLIB_URL)
	tar xf $(BUILD_DIR)/$(ZLIB_TAR) -C $(BUILD_DIR)
	cd $(ZLIB_SRC) && CC=musl-gcc ./configure --static
	$(MAKE) -C $(ZLIB_SRC) -j$(NPROC) CC=musl-gcc

urcu-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(URCU_TAR) $(URCU_URL)
	tar xf $(BUILD_DIR)/$(URCU_TAR) -C $(BUILD_DIR)
	cd $(URCU_SRC) && ./bootstrap && CC=musl-gcc ./configure --enable-static --disable-shared --disable-man-pages
	$(MAKE) -C $(URCU_SRC) -j$(NPROC) CC=musl-gcc LDFLAGS="-static"


# ROOTFS AND INITRAMFS BUILD
rootfs:
	if [ ! -f $(OUT_DIR)/busybox ] || [ ! -f $(OUT_DIR)/init ] || [ ! -f $(OUT_DIR)/tools/* ]; then \
		$(MAKE) tools busybox init; \
	fi
	mkdir -p $(ROOTFS_DIR)/proc
	mkdir -p $(ROOTFS_DIR)/sys
	mkdir -p $(ROOTFS_DIR)/dev
	mkdir -p $(ROOTFS_DIR)/tmp
	mkdir -p $(ROOTFS_DIR)/mnt
	mkdir -p $(ROOTFS_DIR)/admin
	mkdir -p $(ROOTFS_DIR)/bin
	mkdir -p $(ROOTFS_DIR)/bin/others
	mkdir -p $(ROOTFS_DIR)/lib
	ln -sf bin $(ROOTFS_DIR)/sbin
	ln -sf lib $(ROOTFS_DIR)/lib64
	chmod 1777 $(ROOTFS_DIR)/tmp
	chmod 700  $(ROOTFS_DIR)/admin
	cp $(OUT_DIR)/tools/* $(ROOTFS_DIR)/bin/ 2>/dev/null || true
	cp $(OUT_DIR)/busybox $(ROOTFS_DIR)/bin/busybox
	( cd $(ROOTFS_DIR) && ./bin/busybox --install -s ./bin )
	find $(ROOTFS_DIR)/bin -maxdepth 1 -type l -lname '$(ROOTFS_DIR)/bin/busybox' -exec sh -c 'for link do ln -sf busybox "$$link"; done' sh {} +
	ln -sf poweroff $(ROOTFS_DIR)/bin/shutdown
	rm -f $(ROOTFS_DIR)/bin/install
	chmod +x $(ROOTFS_DIR)/bin/* 2>/dev/null || true
	cp $(OUT_DIR)/init $(ROOTFS_DIR)/init
	chmod +x $(ROOTFS_DIR)/init
	( cd $(ROOTFS_DIR) && find . -print0 | cpio --null -o -H newc ) | xz --check=crc32 --lzma2=dict=1MiB > $(IMG_OUT)


# ISO IMAGE BUILD
iso:
	if [ ! -f $(KERNEL_OUT) ] || [ ! -f $(IMG_OUT) ]; then \
		$(MAKE) all; \
	fi
	@if [ ! -d /usr/lib/grub/i386-pc ] || [ ! -d /usr/lib/grub/x86_64-efi ] || [ ! -d /usr/lib/grub/i386-efi ]; then \
		echo "ERROR: Missing GRUB platform modules. Need i386-pc, i386-efi, and x86_64-efi."; \
		echo "Install grub-pc-bin and grub-efi-amd64-bin (or your distro's equivalents)."; \
		exit 1; \
	fi
	$(MAKE) memtest
	$(MAKE) uefi-shell
	rm -rf $(BUILD_DIR)/iso
	mkdir -p $(BUILD_DIR)/iso/boot/grub
	cp $(KERNEL_OUT) $(BUILD_DIR)/iso/boot/blackfox
	cp $(IMG_OUT) $(BUILD_DIR)/iso/boot/blackfox.img
	cp $(MEMTEST_BIOS) $(BUILD_DIR)/iso/boot/memtest
	cp $(MEMTEST_UEFI) $(BUILD_DIR)/iso/boot/memtest.efi
	cp $(UEFI_SHELL_BIN) $(BUILD_DIR)/iso/shellx64.efi
	cp $(ROOT_DIR)/configs/grub.cfg $(BUILD_DIR)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO_OUT) $(BUILD_DIR)/iso -- -volid BLACKFOX


# RELEASE OFFICIAL BUILD
release:
	if [ ! -f $(KERNEL_OUT) ] || [ ! -f $(IMG_OUT) ] || [ ! -f $(ISO_OUT) ]; then \
		echo "ERROR: One or more required files not found. Please run 'make all iso' first."; \
		exit 1; \
	fi
	command -v zstd >/dev/null || { echo "ERROR: zstd is required to create releases."; exit 1; }
	rm -rf $(RELEASE_DIR)/stage
	mkdir -p $(RELEASE_DIR)/stage
	cp $(KERNEL_OUT) $(RELEASE_DIR)/stage/blackfox
	cp $(IMG_OUT) $(RELEASE_DIR)/stage/blackfox.img
	cp $(ISO_OUT) $(RELEASE_ISO)
	tar --zstd -cf $(RELEASE_ARCHIVE) -C $(RELEASE_DIR)/stage blackfox blackfox.img
	sha256sum $(RELEASE_ARCHIVE) > $(RELEASE_SUM)
	sha256sum $(RELEASE_ISO) > $(RELEASE_SUM_ISO)
	@printf 'Release Archive: %s\nChecksum: %s\n' $(RELEASE_ARCHIVE) $(RELEASE_SUM)
	@printf 'Release ISO: %s\nChecksum: %s\n' $(RELEASE_ISO) $(RELEASE_SUM_ISO)

github-release: release
	command -v gh >/dev/null || { echo "ERROR: GitHub CLI (gh) is required. Install it and run 'gh auth login'."; exit 1; }
	gh auth status
	if gh release view $(RELEASE_TAG) >/dev/null 2>&1; then \
		gh release upload $(RELEASE_TAG) $(RELEASE_ISO) $(RELEASE_SUM_ISO) $(RELEASE_ARCHIVE) $(RELEASE_SUM) --clobber; \
	else \
		gh release create $(RELEASE_TAG) $(RELEASE_ISO) $(RELEASE_SUM_ISO) $(RELEASE_ARCHIVE) $(RELEASE_SUM) --title "$(RELEASE_TAG)" --generate-notes; \
	fi


# QEMU TESTING
run:
	if [ ! -f $(KERNEL_OUT) ] || [ ! -f $(IMG_OUT) ]; then \
		echo "ERROR: Kernel or initramfs image not found. Please run 'make all' first."; \
		exit 1; \
	fi
	qemu-system-x86_64 \
	  -kernel $(KERNEL_OUT) \
	  -initrd $(IMG_OUT) \
	  -append "rdinit=/init root=/dev/ram0 rootfstype=ramfs console=tty0 quiet" \
	  -vga std \
	  -m 512M

iso-test:
	if [ ! -f $(OUT_DIR)/$(IMAGE_NAME).iso ]; then \
		echo "ERROR: ISO image not found. Please run 'make iso' first."; \
		exit 1; \
	fi
	qemu-system-x86_64 \
	  -cdrom $(OUT_DIR)/$(IMAGE_NAME).iso \
	  -boot d \
	  -nographic \
	  -m 512M

test:
	if [ ! -f $(KERNEL_OUT) ] || [ ! -f $(IMG_OUT) ]; then \
		echo "ERROR: Kernel or initramfs image not found. Please run 'make all' first."; \
		exit 1; \
	fi
	qemu-system-x86_64 \
	    -kernel $(KERNEL_OUT) \
		-initrd $(IMG_OUT) \
		-append "earlyprintk=ttyS0,115200 rdinit=/init root=/dev/ram0 rootfstype=ramfs console=tty0 console=ttyS0 verbose debug" \
		-nographic -m 512M


# CLEANUP AFTER BUILD OR TESTING
clean:
	cargo clean
	rm -rf $(OUT_DIR)
	rm -rf $(ROOTFS_DIR)
	rm -f Cargo.lock

cleanall: clean
	rm -rf $(BUILD_DIR)
	rm -rf $(ROOT_DIR)/target


help:
	@printf 'Usage: make [target]\n\n'
	@printf 'Targets:\n'
	@printf '  all               Build kernel, initramfs, and tools\n'
	@printf '  kernel            Build the Linux kernel\n'
	@printf '  init              Build the init binary\n'
	@printf '  busybox           Build BusyBox\n'
	@printf '  memtest           Build MemTest86+\n'
	@printf '  uefi-shell        Build UEFI Shell binary\n'
	@printf '  tools             Build all filesystem and disk tools\n'
	@printf '  rootfs            Create root filesystem and initramfs image\n'
	@printf '  iso               Create bootable ISO image\n'
	@printf '  release           Create release archive and checksums\n'
	@printf '  github-release    Create GitHub release (requires gh CLI)\n'
	@printf '  run               Run QEMU with kernel and initramfs\n'
	@printf '  iso-test          Run QEMU with bootable ISO image\n'
	@printf '  test              Run QEMU with verbose output for debugging\n'
	@printf '  clean             Clean build artifacts (kernel, initramfs, tools)\n'
	@printf '  cleanall          Clean all build artifacts including source directories\n'