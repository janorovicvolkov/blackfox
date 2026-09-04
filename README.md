# <center>Black Fox</center>
<strong><center>"Operating System Recovery that saves other Operating Systems"</center></strong>

Black Fox is a minimal recovery-oriented Operating System intended for repairing or
inspecting broken disk images, recovering files, and running maintenance tools in a
small trusted environment.

## Scope

- Create a tiny Linux kernel and a BusyBox-only rootfs, packaged as a squashfs or initrd and ISO.
- Provide a small Rust `init` program as the lightweight userland entrypoint, user utilities are delivered via BusyBox.
- Target use-cases: mount or inspect broken images, run recovery tools, and provide a consistent rescue environment.

## Quick features

- Builds a static BusyBox and a minimal kernel image.
- Bundles static recovery tools via `make tools`: real e2fsprogs and
  dosfstools binaries, [lk](https://github.com/source-liskalinux/lk) a small
  filesystem and shell CLI (protected-path-guarded `cp`, `mv`, `rm`,
  `partition listing`, `mount`, `umount`, and a built-in shell) built on the same
  `liblk` crate as Black Fox own `init`, plus `fox` (a small static terminal editor), util-linux (`fdisk`, `cfdisk`, `sfdisk`, `mount`, `umount`, `findmnt`, `swapon`, `blockdev`, `fsck`), filesystem tools for XFS, Btrfs, and F2FS, ntfs-3g (NTFS mount and
  repair), testdisk (partition and file recovery), and
  rsync. See [Fixing Disks and Partitions](wiki/Fixing-Disks-and-Partitions.md) for
  more informations.
- Produces: `out/blackfox.sfs` (squashfs initrd), `out/blackfox` (kernel image), and
  `out/blackfox.iso` (bootable ISO).
- `make test` runs QEMU in terminal-only mode while `make run` opens a VM window.

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
- `libjpeg` (`libjpeg-dev` in Debian or Ubuntu based)
- `zlib` (`zlib1g-dev` in Debian or Ubuntu based)
- `e2fsprogs` (`libext2fs-dev` in Debian or Ubuntu based)
- `ntfs-3g` (`ntfs-3g-dev` in Debian or Ubuntu based)
- `uuid-dev` (for Debian or Ubuntu based)

## Basic build steps

1. Build everything (kernel, busybox, init, static recovery tools, rootfs, squashfs, iso):

```bash
make all
```

2. Or run targets step-by-step:

```bash
make init       # build Rust init
make busybox    # download and build static busybox
make kernel     # download and build kernel
make tools      # download and statically recovery tools -> out/tools/<binaries>
make rootfs     # assemble root filesystem (installs out/tools/* into /bin)
make squashfs   # create out/blackfox.sfs
make iso        # create bootable ISO
```

See [Building](docs/Building.md) for what each target does in more detail.

## Testing the rootfs (without booting the kernel)

- Blackfox userland is BusyBox-only. The project builds BusyBox statically and uses BusyBox to create all applet symlinks inside the rootfs `bin` directory.
- Verify applets:

```bash
ls -l build/rootfs/bin
build/rootfs/bin/busybox --install -s build/rootfs/bin
ls -l build/rootfs/bin | head
```

- There is no need to create absolute or host symlinks into the `build/rootfs` tree, BusyBox will populate `bin` with the applet links used at runtime.
- Spawn an interactive shell inside the rootfs:

```bash
# with sudo root privileges
sudo chroot build/rootfs /bin/busybox sh
# or without root with proot
proot -S build/rootfs /bin/sh
```

## Customizing kernel configuration

- Edit `configs/kernel.config` to adjust options or enable modules. Then run:

```bash
make kernel
```

## Notes and troubleshooting

- BusyBox should be built statically (`CONFIG_STATIC=y`) so it runs cleanly in the blackfox.sfs.
- `/bin` (already on `$PATH`) is pre-populated with statically-built `e2fsck`, `resize2fs`, `mke2fs`, `dumpe2fs`, `tune2fs`, `fsck.vfat`, `mkfs.vfat`, `lk`, real util-linux (`mount`, `umount`, `fdisk`, `cfdisk`, `sfdisk`, `findmnt`, `swapon`/`swapoff`, `mkswap`, `blockdev`, `fsck`), XFS (`mkfs.xfs`, `xfs_repair`, `xfs_db`, `xfs_growfs`, `xfs_info`, `xfs_admin`), Btrfs (`btrfs`, `mkfs.btrfs`, `fsck.btrfs`), F2FS (`mkfs.f2fs`, `fsck.f2fs`, `dump.f2fs`, `resize.f2fs`, `sload.f2fs`), `ntfs-3g` (plus `ntfsfix`, `ntfsresize`, `ntfsclone`, `mkntfs`), `testdisk`/`photorec`, and `rsync` via `make tools`. See [Fixing Disks and Partitions](wiki/Fixing-Disks-and-Partitions.md) for usage. `/bin/others` itself is where you drop in *extra* tools you build by hand (see [Extending Tools](docs/Extending-Tools.md)).
- BusyBox's own `ls`, `cp`, `mv`, `rm`, `mkdir`, `chmod`, `chown`, `ln`, `mount`, `umount`, `losetup`, `blkid`, `lsblk`, `fdisk`, `swapon`, `swapoff`, `mkswap`, `blockdev`, `fsck` applets are disabled in the `busybox` target `.config` (see [Extending Tools](docs/Extending-Tools.md)) so those commands only ever resolve to the `lk` or `util-linux` binaries above, not two clashing implementations. Because of this, always build through `make all` or `make rootfs` if `make tools` gets skipped, those commands won't exist at all.
- Tool versions are pinned in the `Makefile`: `LK_VERSION` defaults to `main`, while `NCURSES_VERSION`, `UTIL_LINUX_VERSION`, `XFSPROGS_VERSION`, `BTRFSPROGS_VERSION`, `F2FS_TOOLS_VERSION`, `NTFS3G_VERSION`, `TESTDISK_VERSION`, and `RSYNC_VERSION` select the other tool sources. Set them explicitly for reproducible builds, for example `make tools LK_VERSION=v1.0.0`.
- Inspect the squashfs with `unsquashfs -ll out/blackfox.sfs` or mount it as a loop device (requires root).
- If you see kernel config warnings during `merge_config.sh`, confirm the desired options are enabled in `configs/kernel.config`.
- If `out/blackfox.sfs` grows after adding more tools, raise `ramdisk_size=` in `configs/grub.cfg` and pass a matching `RAMDISK_SIZE=` to `make run`/`make test`.
- Full build documentation (Makefile targets, adding your own static tools): [Click here](docs/Home.md).
- Full usage documentation (repairing other distros, systemd, disks): [Click here](wiki/Home.md).

## Contributing
- Open issues or PRs with enhancements, hardware support changes, or recovery tools you find Black Fox useful.
