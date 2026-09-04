# Troubleshooting Black Fox

This page is about **Black Fox** itself failing to boot or misbehaving,
not about repairing some other system. For that, see the other Black Fox
Recovery Wiki pages that explaining it.

## 1. Kernel panic: "VFS: Unable to mount root fs on unknown-block(1,0)"

The most common cause: `blackfox.sfs` didn't get fully copied into the
ramdisk because `ramdisk_size=` is smaller than the actual `.sfs` file size.

- **Check it in your own Linux:**
```bash
ls -lh out/blackfox.sfs
```
- **How to fix it:** raise `ramdisk_size=` (in KB) in `/boot/grub/grub.cfg` (if you using GRUB)
or your own bootloader configuration file.

## 2. Boot just stops with no output, completely black screen

Check whether you're only passing `console=ttyS0` on physical hardware
without an active serial port, also add `console=tty0` so output still
shows up on a normal VGA or framebuffer display (the Black Fox `grub.cfg`
ISO already includes both, but if you're passing a custom `-append` yourself
in your computer or laptop bootloader, don't forget this).

## 3. You get a shell, but a lot of commands say "not found"

Black Fox `busybox` only has the applets enabled in its build config. Check it
in your Black Fox shell:

```bash
# If from busybox:
busybox --list
# Else:
# From "lk -w"
lk -w command-name
# Busybox which tool
which command-name
# Busybox ls
ls /bin
# From "lk -l /bin" for detailed information (executable or not)
lk -l /bin
```

If the command you need isn't there, see [Extending Tools](../docs/Extending-Tools.md)
for how to bake it into the image permanently.