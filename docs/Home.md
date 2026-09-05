<h1><center>Black Fox Build Docs</center></h1>

This is **build-time** documentation: how to compile the `kernel`, `busybox`,
`init`, and the bundled recovery tools, and how to extend the image with
tools of your own.

> *Looking to use an already-built Black Fox image during a recovery
> session instead? That's on the [wiki](../wiki/Home.md) mate.*

## Table of contents

1. [Building](Building.md): Prerequisites, `make` targets
   one-by-one, testing the rootfs, checking image size
2. [Extending Tools](Extending-Tools.md): How the automated
   tools (`e2fsprogs`, `dosfstools`, `lk`) are built and pinned, and
   how to statically build and wire in your own (LVM, LUKS, etc.)
