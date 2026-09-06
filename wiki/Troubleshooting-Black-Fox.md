# Troubleshooting Black Fox

This page is about **Black Fox** itself failing to boot or misbehaving,
not about repairing some other system. For that, see the other Black Fox
Recovery Wiki pages that explaining it.

## 1. Boot just stops with no output, completely black screen

Check whether you're only passing `console=ttyS0` on physical hardware
without an active serial port, also add `console=tty0` so output still
shows up on a normal VGA or framebuffer display (the Black Fox `grub.cfg`
ISO already includes both, but if you're passing a custom `-append` yourself
in your computer or laptop bootloader, don't forget this).

## 2. You get a shell, but a lot of commands say "not found"

Black Fox `busybox` only has the applets enabled in its build config. Check it
in your Black Fox shell:

```bash
busybox --list
lk -w command-name
lk -l /bin
```

If the command you need isn't there, see [Extending Tools](../docs/Extending-Tools.md)
for how to bake it into the image permanently.

## 3. The UEFI Shell entry is missing or does not start

The UEFI Shell is included only in the ISO built after the source-build target
was added. Rebuild it with:

```bash
make uefi-shell
make iso
```

The ISO must contain `/shellx64.efi` at its root. The GRUB entry searches for
that exact path before chainloading it. The entry is visible only when GRUB
reports `grub_platform=efi`, it is intentionally hidden in legacy BIOS mode.

The shell is an x86_64 EFI application, so the machine must be x86_64 and must
be booted in UEFI mode. Secure Boot may also reject a locally built unsigned
EFI application, disable Secure Boot for testing or sign the application with
keys trusted by the firmware.

## 4. Memtest86+ is blank or enters blind mode under UEFI

Memtest86+ is built from its upstream source and uses the firmware-provided UEFI
graphics output. Some firmware exposes an incomplete or incompatible GOP mode,
so Memtest86+ may run without a visible display even though the image loaded.
Try the firmware's native display mode, disable unusual display or CSM settings,
or boot the BIOS Memtest86+ entry when legacy boot is available. A working BIOS
entry does not prove that the UEFI GOP implementation is usable.

If the UEFI Shell displays correctly but Memtest86+ remains blind, the problem
is specific to Memtest86+'s UEFI graphics initialization rather than the ISO's
UEFI loader. If both are invisible, check the firmware's UEFI display support
and the monitor or GPU connection first.