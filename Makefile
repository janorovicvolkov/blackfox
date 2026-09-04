SHELL := /bin/bash
KERNEL_VERSION     ?= 7.2.3
KERNEL_XZ          ?= 7.2.3
BUSYBOX_VERSION    ?= 1.36.1
E2FSPROGS_VERSION  ?= 1.47.4
DOSFSTOOLS_VERSION ?= 4.2
LK_VERSION         ?= main
UTIL_LINUX_VERSION ?= 2.41.2
NTFS3G_VERSION     ?= 2026.7.7
TESTDISK_VERSION   ?= 7.2
RSYNC_VERSION      ?= 3.4.1

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
UTIL_LINUX_BINS := losetup blkid fdisk sfdisk findmnt swapon mkswap blockdev fsck
NTFS3G_SRC      := $(BUILD_DIR)/ntfs-3g-$(NTFS3G_VERSION)
NTFS3G_TAR      := ntfs-3g-$(NTFS3G_VERSION).tar.gz
NTFS3G_URL      := https://github.com/tuxera/ntfs-3g/archive/$(NTFS3G_VERSION)/$(NTFS3G_TAR)
TESTDISK_SRC    := $(BUILD_DIR)/testdisk-$(TESTDISK_VERSION)
TESTDISK_TAR    := testdisk-$(TESTDISK_VERSION).tar.bz2
TESTDISK_URL    := https://www.cgsecurity.org/$(TESTDISK_TAR)
RSYNC_SRC       := $(BUILD_DIR)/rsync-$(RSYNC_VERSION)
RSYNC_TAR       := rsync-$(RSYNC_VERSION).tar.gz
RSYNC_URL       := https://rsync.samba.org/ftp/rsync/src/$(RSYNC_TAR)
INIT_TARGET     := x86_64-unknown-linux-musl
INIT_BIN        := $(ROOT_DIR)/target/$(INIT_TARGET)/release/blackfox
IMAGE_NAME      ?= blackfox
KERNEL_OUT      := $(OUT_DIR)/$(IMAGE_NAME)
SFS_OUT         := $(OUT_DIR)/$(IMAGE_NAME).sfs
RAMDISK_SIZE    ?= 262144

NPROC := $(shell nproc)

.PHONY: all kernel busybox init tools lk-tool util-linux-tool ntfs3g-tool testdisk-tool rsync-tool rootfs squashfs iso run test clean cleanall

all: init busybox kernel tools rootfs squashfs iso

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
	touch $@
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
	           CONFIG_MKSWAP CONFIG_BLOCKDEV CONFIG_FSCK CONFIG_LS; do \
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
# LVM (lvm2) and LUKS (cryptsetup) are still NOT auto-built here, both pull
# in heavy dependency chains (libdevmapper, libpopt, json-c, libargon2, ...)
# that are fragile to static-link reliably across distros. Kernel-side
# support (device-mapper, dm-crypt) is already enabled in
# configs/kernel.config. See docs/Extending-Tools.md for manual
# static-build instructions if you need those userspace tools too.

tools: e2fsprogs-tool dosfstools-tool lk-tool util-linux-tool ntfs3g-tool testdisk-tool rsync-tool

e2fsprogs-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(E2FSPROGS_TAR) $(E2FSPROGS_URL)
	tar xf $(BUILD_DIR)/$(E2FSPROGS_TAR) -C $(BUILD_DIR)
	cd $(E2FSPROGS_SRC) && ./configure --enable-elf-shlibs=no --disable-nls \
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

util-linux-tool:
	mkdir -p $(BUILD_DIR)
	wget -O $(BUILD_DIR)/$(UTIL_LINUX_TAR) $(UTIL_LINUX_URL)
	tar xf $(BUILD_DIR)/$(UTIL_LINUX_TAR) -C $(BUILD_DIR)
	cd $(UTIL_LINUX_SRC) && ./configure --disable-shared --disable-liblastlog2 \
		--without-python --disable-pylibmount --without-ncursesw --without-ncurses \
		--without-systemd --without-udev --disable-chfn-chsh --disable-login \
		--disable-nologin --disable-su --disable-runuser --disable-agetty \
		--disable-setpriv --disable-rfkill --disable-lsblk --disable-mount \
		--disable-umount CFLAGS="-static" LDFLAGS="-static"
	$(MAKE) -C $(UTIL_LINUX_SRC) -j$(NPROC) LDFLAGS="-static" $(UTIL_LINUX_BINS)
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
	cd $(NTFS3G_SRC) && ./autogen.sh && ./configure --disable-shared \
		--with-fuse=internal --disable-plugins \
		CFLAGS="-static" LDFLAGS="-static"
	$(MAKE) -C $(NTFS3G_SRC) -j$(NPROC)
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
	cd $(TESTDISK_SRC) && ./configure
	$(MAKE) -C $(TESTDISK_SRC) -j$(NPROC) static
	mkdir -p $(OUT_DIR)/tools
	cp $(TESTDISK_SRC)/src/testdisk_static $(OUT_DIR)/tools/testdisk
	cp $(TESTDISK_SRC)/src/photorec_static $(OUT_DIR)/tools/photorec
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

# ROOTFS BUILD

rootfs: init busybox kernel tools
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

iso: squashfs
	mkdir -p $(BUILD_DIR)/iso/boot/grub
	cp $(KERNEL_OUT) $(BUILD_DIR)/iso/boot/blackfox
	cp $(SFS_OUT) $(BUILD_DIR)/iso/boot/blackfox.sfs
	cp $(ROOT_DIR)/configs/grub.cfg $(BUILD_DIR)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(OUT_DIR)/$(IMAGE_NAME).iso $(BUILD_DIR)/iso

run:
	qemu-system-x86_64 \
	  -kernel $(KERNEL_OUT) \
	  -initrd $(SFS_OUT) \
	  -append "root=/dev/ram0 rootfstype=squashfs ramdisk_size=$(RAMDISK_SIZE) console=ttyS0 quiet" \
	  -m 512M

test:
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