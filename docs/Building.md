# Building

> *This is build-time documentation, for using Black Fox during an actual
> recovery session see the [wiki](../wiki/Home.md) instead.*

## Prerequisites

- `make`
- `wget`
- `tar`
- `xz`
- C toolchain (`gcc` + `binutils`)
- `mksquashfs`
- GRUB toolchain (`grub-mkrescue` + `xorriso`)
- `qemu-system-x86_64`
- Rust toolchain (`rustup` + `cargo`)
- `git`
- `autoconf`
- `automake`
- `libtool`
- `ncurses` (`libncurses-dev` in Debian or Ubuntu based)
- `libjpeg` (`libjpeg-dev` in Debian or Ubuntu based)
- `zlib` (`zlib1g-dev` in Debian or Ubuntu based)
- `e2fsprogs` (`libext2fs-dev` in Debian or Ubuntu based)
- `ntfs-3g` (`ntfs-3g-dev` in Debian or Ubuntu based)
- `uuid-dev` (for Debian or Ubuntu based)

## Quick build

```bash
make all
```

Builds everything: `kernel`, `busybox`, `init`, the static recovery tools
(`e2fsprogs`, `dosfstools`, `lk`, `util-linux`, `ntfs-3g`, `testdisk`,
`rsync`), assembles the rootfs, then packs it into a
squashfs and a bootable ISO.

Or run each stage individually:

```bash
make init       # build the rust init
make busybox    # download and build static busybox
make kernel     # download and build the kernel
make tools      # download and statically build all recovery tools -> out/tools/<binaries>
make rootfs     # assemble root filesystem
make squashfs   # create out/blackfox.sfs
make iso        # create out/blackfox.iso
```

## Makefile targets, one by one

### `kernel`

Downloads `configs/kernel.config` pinned kernel version (`KERNEL_VERSION` or `KERNEL_XZ`),
starts from `tinyconfig`, merges in `configs/kernel.config`, then builds `bzImage`. Edit
`configs/kernel.config` to change kernel options, then re-run `make kernel`.

### `busybox`

Downloads BusyBox (`BUSYBOX_VERSION`), configures with `make defconfig`, forces
`CONFIG_STATIC=y`, disables `CONFIG_TC`, and disables the applets now provided by `lk`
and `util-linux` (`ls`, `cp`, `mv`, `rm`, `mkdir`, `chmod`, `chown`, `ln`, `mount`,
`umount`, `losetup`, `blkid`, `lsblk`, `fdisk`, `swapon`, `swapoff`, `mkswap`, `blockdev`,
`fsck`) so there's exactly one binary providing each command. See [Extending Tools](Extending-Tools.md) for why. Then builds. Statically linked so it runs without a dynamic linker.

### `init`

Cross-compiles the project's own Rust `init` (`src/main.rs`, built on the
`liblk` crate) to `x86_64-unknown-linux-musl`, producing a single static
binary that becomes PID 1.

### `tools`

Runs `e2fsprogs-tool`, `dosfstools-tool`, `lk-tool`, `util-linux-tool`, `ntfs3g-tool`,
`testdisk-tool`, and `rsync-tool`. See [Extending Tools](Extending-Tools.md) for what
each one produces and how to pin or bump their versions (`E2FSPROGS_VERSION`,
`DOSFSTOOLS_VERSION`, `LK_VERSION`, `UTIL_LINUX_VERSION`, `NTFS3G_VERSION`, `TESTDISK_VERSION`, `RSYNC_VERSION`).

Because `busybox` own copies of `mount`, `cp`, etc. are compiled out (see above), 
rootfs depends on tools running first, always build through `make all` or `make rootfs`
rather than invoking individual sub-targets like `util-linux-tool` on their own and
skipping the rest.

LVM (`lvm2`) and LUKS (`cryptsetup`) userspace tools are not auto-built here, both pull
in dependency chains (`libdevmapper`, `libpopt`, `json-c`, `libargon2`, etc.) that are
fragile to static-link reliably across build hosts. Kernel-side support (device-mapper
and dm-crypt) is already enabled in `configs/kernel.config`. See
[Extending Tools](Extending-Tools.md) for manual static-build instructions if you need
the userspace side too.

### `rootfs`

Assembles `build/rootfs`: creates `/proc`, `/sys`, `/dev`, `/tmp`, `/mnt`,
`/admin`, `/bin`, `/bin/others`, `/lib` (`/sbin` and `/lib64` symlinked to `/bin` and
`/lib`), copies `out/tools/*` into `/bin`, installs `busybox` applet symlinks, and
drops in `init`.

### `squashfs` and `iso`

Packs the rootfs into `out/blackfox.sfs`, then assembles a GRUB-bootable ISO
at `out/blackfox.iso` using `configs/grub.cfg`.

### `run` or `test`

Boot the built image in QEMU. `run` opens a VM window while `test` runs
`-nographic -serial mon:stdio` for terminal-only output, handy for fast
iteration.

### `clean` or `cleanall`

`clean` removes `out/`, `Cargo.lock`, and runs `cargo clean`. `cleanall`
additionally wipes `build/` and `target/` (forces every download or build
step to start over).

## Testing the rootfs without booting the kernel

```bash
ls -l build/rootfs/bin
build/rootfs/bin/busybox --install -s build/rootfs/bin
ls -l build/rootfs/bin | head
```

`busybox` populates `bin` with applet symlinks itself, no need to create
host symlinks by hand. To poke around interactively:

```bash
sudo chroot build/rootfs /bin/busybox sh      # with root
proot -S build/rootfs /bin/sh                 # without root
```

## Checking the final image size

```bash
ls -lh out/blackfox.sfs
```

If it grows significantly (e.g. after adding tools), raise `ramdisk_size=`
in `configs/grub.cfg` and pass a matching `RAMDISK_SIZE=` to `make run` or
`make test` otherwise the image gets truncated while being copied into
`/dev/ram0` and boot fails. See
[Booting Black Fox](../wiki/Booting-Black-Fox.md).

## Contributing

Open issues or PRs with enhancements, hardware support changes, or recovery
tools you find Black Fox useful with.