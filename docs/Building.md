# Building

> *This is build-time documentation, for using Black Fox during an actual
> recovery session see the [wiki](../wiki/Home.md) instead.*

## Prerequisites

- `make`
- `wget`
- `tar`
- `lzip` (for GNU ddrescue)
- `xz`
- `zstd` (for release archives)
- C toolchain (`gcc` + `binutils`)
- C++ toolchain (`g++` with static libstdc++/libgcc support)
- `cpio`
- GRUB and ISO tools (`grub-mkrescue` + `xorriso`)
- `qemu-system-x86_64`
- Rust toolchain (`rustup` + `cargo`)
- `git`
- `python3` and `nasm` (required by the EDK2 UEFI Shell build)
- `autoconf`
- `automake`
- `libtool`
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
(`e2fsprogs`, `dosfstools`, `lk`, `ncurses`, `util-linux`, `xfsprogs`,
`btrfs-progs`, `f2fs-tools`, `ntfs-3g`, `testdisk`,
`rsync`, `ddrescue`, `smartmontools`, `mdadm`, `gdisk`, `exfatprogs`),
assembles the rootfs, then packs it into a
initramfs and a bootable ISO.

Or run each stage individually:

```bash
make init       # build the rust init
make busybox    # download and build static busybox
make kernel     # download and build the kernel
make tools      # download and statically build all recovery tools -> out/tools/<binaries>
make rootfs     # create out/blackfox.img
make memtest    # build upstream Memtest86+ for BIOS and UEFI
make uefi-shell # build the EDK2 UEFI Shell from source
make iso        # create out/blackfox.iso
make release    # create out/release/blackfox-<tag>-x86_64.tar.zst
```

`make release` packages the kernel, initramfs, and ISO into a Zstandard-compressed
tar archive and writes a SHA-256 checksum beside it. Set `RELEASE_TAG`, for
example `make release RELEASE_TAG=v1.0.0`, to choose the artifact name.

After installing and authenticating the GitHub CLI with `gh auth login`, publish
the archive with `make github-release RELEASE_TAG=v1.0.0`.

## Makefile targets, one by one

### `kernel`

Downloads `configs/kernel.config` pinned kernel version (`KERNEL_VERSION` or `KERNEL_XZ`),
starts from `tinyconfig`, merges in `configs/kernel.config`, then builds `bzImage`. Edit
`configs/kernel.config` to change kernel options, then re-run `make kernel`.

### `busybox`

Downloads `busybox` (`BUSYBOX_VERSION`), configures with `make defconfig`, forces
`CONFIG_STATIC=y`, disables `CONFIG_TC`, and disables the applets now provided by `lk`
and `util-linux` (`cp`, `mv`, `rm`, `mkdir`, `chmod`, `chown`, `ln`, `mount`,
`umount`, `losetup`, `blkid`, `lsblk`, `fdisk`, `swapon`, `swapoff`, `mkswap`, `blockdev`,
`fsck`) so there's exactly one binary providing each command. See [Extending Tools](Extending-Tools.md) for why. Then builds. Statically linked so it runs without a dynamic linker.

### `init`

Cross-compiles the project's own Rust `init` (`src/init.rs`, built on the
`liblk` crate) to `x86_64-unknown-linux-musl`, producing a single static
binary that becomes PID 1.

### `tools`

Runs `e2fsprogs-tool`, `dosfstools-tool`, `lk-tool`, `ncurses-tool`,
`util-linux-tool`, `xfsprogs-tool`, `btrfs-progs-tool`, `f2fs-tools-tool`, `ntfs3g-tool`,
`testdisk-tool`, `rsync-tool`, `ddrescue-tool`, `smartmontools-tool`, `mdadm-tool`,
`gdisk-tool`, and `exfatprogs-tool`. See [Extending Tools](Extending-Tools.md) for what
each one produces and how to pin or bump their versions (`E2FSPROGS_VERSION`,
`DOSFSTOOLS_VERSION`, `LK_VERSION`, `NCURSES_VERSION`, `UTIL_LINUX_VERSION`,
`XFSPROGS_VERSION`, `BTRFSPROGS_VERSION`, `F2FS_TOOLS_VERSION`, `NTFS3G_VERSION`,
`TESTDISK_VERSION`, `RSYNC_VERSION`, `DDRESCUE_VERSION`, `SMARTMONTOOLS_VERSION`,
`MDADM_VERSION`, `GDISK_VERSION`, and `EXFATPROGS_VERSION`).

`ncurses-tool` builds a static wide-character ncurses library first because
`cfdisk` needs it. `util-linux-tool` then builds static `agetty`, `cfdisk`,
`mount`, `umount`, and the other selected util-linux commands. The staged ncurses
library is used only during the build and is not copied into the image.

The rootfs depends on the selected static tools being available, so always build
through `make all` or `make rootfs` rather than invoking individual sub-targets
like `util-linux-tool` on their own and skipping the rest.

LVM (`lvm2`) and LUKS (`cryptsetup`) userspace tools are not auto-built here, both pull
in dependency chains (`libdevmapper`, `libpopt`, `json-c`, `libargon2`, etc.) that are
fragile to static-link reliably across build hosts. Kernel-side support (device-mapper
and dm-crypt) is already enabled in `configs/kernel.config`. See
[Extending Tools](Extending-Tools.md) for manual static-build instructions if you need
the userspace side too.

### `rootfs`

Assembles `build/rootfs`: creates `/proc`, `/sys`, `/dev`, `/tmp`, `/mnt`,
`/admin`, `/bin`, `/bin/others`, `/lib` (`/sbin` and `/lib64` symlinked to `/bin` and
`/lib`), copies `out/tools/*` into `/bin`, installs `busybox` applet symlinks,
restores the direct `poweroff` and `reboot` commands, links `shutdown` to
`poweroff`, and drops in `init`. After that, it makes an initramfs image at
`out/blackfox.img`.

### `iso`

Packs the rootfs into `out/blackfox.img`, then assembles a GRUB-bootable ISO
at `out/blackfox.iso` using `configs/grub.cfg`. The target also builds
Memtest86+ and the EDK2 UEFI Shell, then places them in the ISO as
`/boot/memtest`, `/boot/memtest.efi`, and `/shellx64.efi`.

### `memtest`

Downloads and builds the upstream Memtest86+ source selected by
`MEMTEST86_VERSION`. The resulting image is copied to `out/memtest` for the
legacy BIOS GRUB path and `out/memtest.efi` for the UEFI GRUB path. The ISO
menu uses the UEFI image through GRUB.

### `uefi-shell`

Clones the pinned EDK2 source tag selected by `UEFI_SHELL_VERSION`, initializes
the required submodules, builds `ShellPkg/ShellPkg.dsc` with the GCC toolchain,
and copies the resulting x86_64 EFI application to `out/shellx64.efi`. The ISO
menu uses the UEFI Shell through GRUB.

To add Black Fox to an existing GRUB installation, copy the kernel and initramfs
to `/boot`, then copy [40_custom.blackfox](40_custom.blackfox) to
`/etc/grub.d/40_custom` or merge its `menuentry` into that file. Make the file
executable and regenerate GRUB:

```bash
sudo cp out/blackfox /boot/blackfox
sudo cp out/blackfox.img /boot/blackfox.img
sudo cp docs/40_custom.blackfox /etc/grub.d/40_blackfox
sudo chmod +x /etc/grub.d/40_blackfox
sudo update-grub
```

The provided entry searches for `/boot/blackfox`. If `/boot` is a separate
GRUB partition and the files are copied to its top level, use `/blackfox` and
`/blackfox.img` in the entry instead. Verify the generated menu before
rebooting and keep the existing OS entry available.

### `run`, `test`, or `iso-test`

Boot the built image in QEMU:

```bash
make run
```

`run` opens a VM window and displays the recovery banner and shell on the
guest's VGA console. Close the QEMU window, or press `Ctrl+C` in the terminal
that launched it, to stop QEMU.

For terminal-only testing without a VM window, use:

```bash
make test
```

To test the actual ISO and GRUB boot path in the terminal, use:

```bash
make iso-test
```

Build the ISO first with `make iso`. Stop either terminal-only test with
`Ctrl+C`.

The initramfs is compressed with conservative XZ settings (`LZMA2` with a
1 MiB dictionary and `CRC32`) because the kernel's built-in XZ decoder does not
accept every userspace `xz` configuration.

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

## Contributing

Open issues or PRs with enhancements, hardware support changes, or recovery
tools you find Black Fox useful with.