SHELL              := /bin/bash
KERNEL_VERSION     ?= 7.2.3
KERNEL_XZ          ?= 7.2.3
BUSYBOX_VERSION    ?= 1.36.1
E2FSPROGS_VERSION  ?= 1.47.4
DOSFSTOOLS_VERSION ?= 4.2
LK_VERSION         ?= main
UTIL_LINUX_VERSION ?= 2.41.2
NTFS3G_VERSION     ?= 2026.7.7
TESTDISK_VERSION   ?= 7.2
RSYNC_VERSION      ?= 3.5.0
XFSPROGS_VERSION   ?= 7.1.1
BTRFSPROGS_VERSION ?= 7.1
F2FS_TOOLS_VERSION ?= 1.16.0
INIH_VERSION       ?= r58
ZLIB_VERSION       ?= 1.3.1
URCU_VERSION       ?= 0.15.0
NCURSES_VERSION    ?= 6.5

ROOT_DIR        := $(shell pwd)
BUILD_DIR       := $(ROOT_DIR)/build
OUT_DIR         := $(ROOT_DIR)/out
ROOTFS_DIR      := $(BUILD_DIR)/rootfs
KERNEL_SRC      := $(BUILD_DIR)/linux-$(KERNEL_XZ)
KERNEL_TAR      := linux-$(KERNEL_XZ).tar.xz
KERNEL_URL      := https://www.kernel.org/pub/linux/kernel/v7.x/$(KERNEL_TAR)
KERNEL_IMG      := $(KERNEL_SRC)/arch/x86/boot/bzImage
BUSYBOX_SRC     := $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)
BUSYBOX_TAR     := busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_URL     := https://busybox.net/downloads/$(BUSYBOX_TAR)
E2FSPROGS_SRC   := $(BUILD_DIR)/e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_TAR   := e2fsprogs-$(E2FSPROGS_VERSION).tar.gz
E2FSPROGS_URL   := https://github.com/tytso/e2fsprogs/archive/refs/tags/v$(E2FSPROGS_VERSION).tar.gz
DOSFSTOOLS_SRC  := $(BUILD_DIR)/dosfstools-$(DOSFSTOOLS_VERSION)
DOSFSTOOLS_TAR  := dosfstools-$(DOSFSTOOLS_VERSION).tar.gz
DOSFSTOOLS_URL  := https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VERSION)/dosfstools-$(DOSFSTOOLS_VERSION).tar.gz
LK_SRC          := $(BUILD_DIR)/lk-$(LK_VERSION)
LK_REPO         := https://github.com/source-liskalinux/lk.git
UTIL_LINUX_SRC  := $(BUILD_DIR)/util-linux-$(UTIL_LINUX_VERSION)
UTIL_LINUX_TAR  := util-linux-$(UTIL_LINUX_VERSION).tar.xz
UTIL_LINUX_URL  := https://www.kernel.org/pub/linux/utils/util-linux/v2.41/$(UTIL_LINUX_TAR)
UTIL_LINUX_BINS := losetup blkid fdisk sfdisk findmnt swapon mkswap blockdev fsck mount umount
UTIL_LINUX_STATIC_PROGRAMS := blkid,fdisk,losetup,sfdisk,mount,umount
UTIL_LINUX_BINS += cfdisk
UTIL_LINUX_STATIC_PROGRAMS := $(UTIL_LINUX_STATIC_PROGRAMS),cfdisk
NCURSES_SRC     := $(BUILD_DIR)/ncurses-$(NCURSES_VERSION)
NCURSES_TAR     := ncurses-$(NCURSES_VERSION).tar.gz
NCURSES_URL     := https://invisible-island.net/archives/ncurses/$(NCURSES_TAR)
NCURSES_PREFIX  := $(NCURSES_SRC)/stage
NTFS3G_SRC      := $(BUILD_DIR)/ntfs-3g-$(NTFS3G_VERSION)
NTFS3G_TAR      := ntfs-3g-$(NTFS3G_VERSION).tar.gz
NTFS3G_URL      := https://github.com/tuxera/ntfs-3g/archive/$(NTFS3G_VERSION)/$(NTFS3G_TAR)
TESTDISK_SRC    := $(BUILD_DIR)/testdisk-$(TESTDISK_VERSION)
TESTDISK_TAR    := testdisk-$(TESTDISK_VERSION).tar.bz2
TESTDISK_URL    := https://www.cgsecurity.org/$(TESTDISK_TAR)
RSYNC_SRC       := $(BUILD_DIR)/rsync-$(RSYNC_VERSION)
RSYNC_TAR       := rsync-$(RSYNC_VERSION).tar.gz
RSYNC_URL       := https://rsync.samba.org/ftp/rsync/src/$(RSYNC_TAR)
XFSPROGS_SRC    := $(BUILD_DIR)/xfsprogs-$(XFSPROGS_VERSION)
XFSPROGS_TAR    := xfsprogs-$(XFSPROGS_VERSION).tar.xz
XFSPROGS_URL    := https://www.kernel.org/pub/linux/utils/fs/xfs/xfsprogs/$(XFSPROGS_TAR)
BTRFSPROGS_SRC  := $(BUILD_DIR)/btrfs-progs-$(BTRFSPROGS_VERSION)
BTRFSPROGS_TAR  := btrfs-progs-$(BTRFSPROGS_VERSION).tar.gz
BTRFSPROGS_URL  := https://github.com/kdave/btrfs-progs/archive/refs/tags/v$(BTRFSPROGS_VERSION).tar.gz
F2FS_TOOLS_SRC  := $(BUILD_DIR)/f2fs-tools-$(F2FS_TOOLS_VERSION)
F2FS_TOOLS_TAR  := f2fs-tools-$(F2FS_TOOLS_VERSION).tar.gz
F2FS_TOOLS_URL  := https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/f2fs-tools-$(F2FS_TOOLS_VERSION).tar.gz
INIH_SRC        := $(BUILD_DIR)/inih-$(INIH_VERSION)
INIH_TAR        := inih-$(INIH_VERSION).tar.gz
INIH_URL        := https://github.com/benhoyt/inih/archive/refs/tags/$(INIH_VERSION).tar.gz
ZLIB_SRC        := $(BUILD_DIR)/zlib-$(ZLIB_VERSION)
ZLIB_TAR        := zlib-$(ZLIB_VERSION).tar.gz
ZLIB_URL        := https://github.com/madler/zlib/archive/refs/tags/v$(ZLIB_VERSION).tar.gz
URCU_SRC        := $(BUILD_DIR)/userspace-rcu-$(URCU_VERSION)
URCU_TAR        := userspace-rcu-$(URCU_VERSION).tar.gz
URCU_URL        := https://github.com/urcu/userspace-rcu/archive/refs/tags/v$(URCU_VERSION).tar.gz
INIT_TARGET     := x86_64-unknown-linux-musl
INIT_BIN        := $(ROOT_DIR)/target/$(INIT_TARGET)/release/init
FOX_BIN         := $(ROOT_DIR)/target/$(INIT_TARGET)/release/fox
IMAGE_NAME      ?= blackfox
KERNEL_OUT      := $(OUT_DIR)/$(IMAGE_NAME)
SFS_OUT         := $(OUT_DIR)/$(IMAGE_NAME).sfs
RAMDISK_SIZE    ?= 262144

NPROC := $(shell nproc)

.PHONY: all kernel busybox init fox-tool tools lk-tool ncurses-tool util-linux-tool ntfs3g-tool testdisk-tool rsync-tool inih-tool zlib-tool urcu-tool xfsprogs-tool btrfs-progs-tool f2fs-tools-tool rootfs squashfs iso run test clean cleanall

all: iso

# KERNEL BUILD

kernel:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(KERNEL_TAR) $(KERNEL_URL)
	tar xf $(BUILD_DIR)/$(KERNEL_TAR) -C $(BUILD_DIR)
	cd $(KERNEL_SRC) && \
		make tinyconfig && \
		$(KERNEL_SRC)/scripts/kconfig/merge_config.sh -O $(KERNEL_SRC) $(KERNEL_SRC)/.config $(ROOT_DIR)/configs/kernel.config && \
		make alldefconfig && \
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
	# Disable the applets now provided by "lk" (guarded cp/mv/rm/mkdir/
	# chmod/chown/ln) and by the real util-linux binaries from
	# "util-linux-tool" (mount/umount/losetup/blkid/lsblk/fdisk/sfdisk/
	# swapon/swapoff/mkswap/blockdev/fsck), so there's exactly one binary
	# providing each command on $PATH instead of two clashing
	# implementations. Some of these config symbols may not exist in every
	# BusyBox version (e.g. no CONFIG_SFDISK applet), the sed is a no-op
	# for those, which is harmless. See docs/Extending-Tools.md.
	for cfg in CONFIG_CP CONFIG_MV CONFIG_RM CONFIG_MKDIR CONFIG_CHMOD CONFIG_CHOWN CONFIG_LN \
	           CONFIG_MOUNT CONFIG_UMOUNT CONFIG_LOSETUP CONFIG_BLKID CONFIG_LSBLK \
	           CONFIG_FDISK CONFIG_SFDISK CONFIG_FINDMNT CONFIG_SWAPON CONFIG_SWAPOFF \
	           CONFIG_MKSWAP CONFIG_BLOCKDEV CONFIG_FSCK CONFIG_LS CONFIG_WHICH; do \
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

fox-tool:
	rustup target add $(INIT_TARGET) 2>/dev/null || true
	cargo build --release --target $(INIT_TARGET) --bin fox
	mkdir -p $(OUT_DIR)/tools
	cp $(FOX_BIN) $(OUT_DIR)/tools/fox
	strip $(OUT_DIR)/tools/fox 2>/dev/null || true
	chmod +x $(OUT_DIR)/tools/fox

# TOOLS BUILD
#
# BusyBox's own "mkfs.ext2" "fdisk" or "fsck" are minimal implementations, not
# enough for real ext4 repair or FAT32 repair. These two are built as
# fully static binaries and dropped into /bin so real e2fsck, resize2fs, or
# fsck.vfat are available at boot without needing a package manager.
#
# "lk" (https://github.com/source-liskalinux/lk) is a small filesystem or shell
# CLI built on the same "liblk" crate as this project's own init. Unlike
# e2fsprogs or dosfstools it's pure Rust, so it's cross-compiled to the musl
# target instead of "./configure ... -static" -- same approach as the "init"
# target below. It adds a protected-path-guarded cp/mv/rm/chmod/chown, a
# Rust-only "-P/--partition-list", "--mount"/"--umount", and a built-in
# "lk -S" shell.
#
# "util-linux" replaces BusyBox's minimal mount/umount/fdisk/lsblk/etc with
# the real thing (full GPT editing via sfdisk, findmnt, proper mount option
# parsing, ...). Only the handful of block-device/mount binaries are built
# (UTIL_LINUX_BINS below), not the whole util-linux suite (no login/su/
# chsh/agetty BusyBox already covers basic login-less shell use, and
# those need PAM).
#
# "ntfs-3g" adds NTFS mount/repair (mount.ntfs-3g, ntfsfix, ntfsresize,
# ntfsclone, mkntfs) on top of the kernel's own read/write ntfs3 driver
# useful as a fallback and for the ntfsprogs repair utilities the kernel
# driver doesn't provide. Built with its internal FUSE ("fuse-lite") so it
# doesn't need a libfuse dependency or a FUSE kernel module beyond what's
# already in configs/kernel.config.
#
# "testdisk"/"photorec" (partition-table and deleted-file recovery) and
# "rsync" (fast backups before risky operations) round out the recovery
# toolkit. testdisk ships its own "make static" target upstream.
#
# OpenZFS is not included here: its userspace tools require an out-of-tree
# kernel module, which this tiny built-in kernel does not build or package.
#
# LVM (lvm2) and LUKS (cryptsetup) are still NOT auto-built here, both pull
# in heavy dependency chains (libdevmapper, libpopt, json-c, libargon2, ...)
# that are fragile to static-link reliably across distros. Kernel-side
# support (device-mapper, dm-crypt) is already enabled in
# configs/kernel.config. See docs/Extending-Tools.md for manual
# static-build instructions if you need those userspace tools too.

tools: cleanall e2fsprogs-tool dosfstools-tool fox-tool lk-tool util-linux-tool ntfs3g-tool testdisk-tool rsync-tool xfsprogs-tool btrfs-progs-tool f2fs-tools-tool
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
		--disable-nologin --disable-su --disable-runuser --disable-agetty \
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

# ROOTFS BUILD

rootfs: tools init busybox
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
	chmod +x $(ROOTFS_DIR)/bin/* 2>/dev/null || true
	cp $(OUT_DIR)/busybox $(ROOTFS_DIR)/bin/busybox
	chmod +x $(ROOTFS_DIR)/bin/busybox
	$(ROOTFS_DIR)/bin/busybox --install -s $(ROOTFS_DIR)/bin
	cp $(OUT_DIR)/init $(ROOTFS_DIR)/init
	chmod +x $(ROOTFS_DIR)/init

squashfs: rootfs
	mkdir -p $(OUT_DIR)
	mksquashfs $(ROOTFS_DIR) $(SFS_OUT) -comp xz -noappend

iso: squashfs kernel
	mkdir -p $(BUILD_DIR)/iso/boot/grub
	cp $(KERNEL_OUT) $(BUILD_DIR)/iso/boot/blackfox
	cp $(SFS_OUT) $(BUILD_DIR)/iso/boot/blackfox.sfs
	cp $(ROOT_DIR)/configs/grub.cfg $(BUILD_DIR)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(OUT_DIR)/$(IMAGE_NAME).iso $(BUILD_DIR)/iso

run:
	if [ ! -f $(KERNEL_OUT) ] || [ ! -f $(SFS_OUT) ]; then \
		echo "ERROR: Kernel or SquashFS image not found. Please run 'make iso' first."; \
		exit 1; \
	fi
	qemu-system-x86_64 \
	  -kernel $(KERNEL_OUT) \
	  -initrd $(SFS_OUT) \
	  -append "root=/dev/ram0 rootfstype=squashfs ramdisk_size=$(RAMDISK_SIZE) console=ttyS0 quiet" \
	  -m 512M

test:
	if [ ! -f $(KERNEL_OUT) ] || [ ! -f $(SFS_OUT) ]; then \
		echo "ERROR: Kernel or SquashFS image not found. Please run 'make iso' first."; \
		exit 1; \
	fi
	qemu-system-x86_64 \
	  -kernel $(KERNEL_OUT) \
	  -initrd $(SFS_OUT) \
	  -append "root=/dev/ram0 rootfstype=squashfs ramdisk_size=$(RAMDISK_SIZE) console=ttyS0 quiet" \
	  -nographic -serial mon:stdio -monitor none -no-reboot -m 512M

clean:
	cargo clean
	rm -rf $(OUT_DIR)
	rm -f Cargo.lock

cleanall: clean
	rm -rf $(BUILD_DIR)
	rm -rf $(ROOT_DIR)/target