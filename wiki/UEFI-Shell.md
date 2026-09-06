# UEFI Shell

Black Fox can boot the EDK2 UEFI Shell from its GRUB ISO menu. The shell is a
firmware-level environment, not the shell inside Black Fox. It is separate
from the Black Fox environment and runs before Black Fox starts.

## Start the shell

Write the generated ISO to USB, boot it, and select `UEFI Shell` entry. The
entry searches for `/shellx64.efi` and chainloads it. It is shown only when
GRUB reports the `efi` platform. Legacy BIOS firmware cannot execute this EFI
application directly.

## Basic commands

The shell normally assigns filesystem mappings such as `fs0:` and `fs1:`. Refresh
the mappings and inspect a filesystem with:

```text
map -r
fs0:
dir
```

Common commands include:

```text
help
map -r
fs0:
dir
cd EFI
type startup.nsh
reset
```

Mappings and device numbers can change between machines and boots. Check the
output of `map -r` instead of assuming that `fs0:` is the intended partition.
Use `help <command>` for command-specific syntax.

## Relationship to Black Fox

The UEFI Shell does not mount the Black Fox initramfs and does not provide the
Linux recovery tools under `/bin`. Exit or reset from the shell and choose
`Black Fox` in GRUB to start the Linux recovery environment.

The shell is useful for inspecting EFI filesystems, checking firmware-visible
boot files, and launching other compatible EFI applications. It cannot run
Linux binaries or repair Linux filesystems with Black Fox utilities.

## Secure Boot and architecture

The shell is locally built and normally unsigned. Secure Boot firmware may
reject it even when the ISO and GRUB menu are correct. Disable Secure Boot for
testing or sign the EFI application with a key trusted by the firmware.

The included binary targets x86_64 UEFI systems. It is not suitable for ARM64,
IA32, or other firmware architectures.

If the entry is missing or fails to start, see [Troubleshooting Black Fox](Troubleshooting-Black-Fox.md).
