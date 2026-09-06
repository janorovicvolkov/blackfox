#![no_std]
#![no_main]
use core::arch::asm;
use core::panic::PanicInfo;

const MIN_TEST_ADDRESS: u64 = 16 * 1024 * 1024;
const PAGE_SIZE: u64 = 4096;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    halt()
}

#[unsafe(no_mangle)]
extern "C" fn rust_eh_personality() {}

fn halt() -> ! {
    loop {
        unsafe { asm!("cli", "hlt") }
    }
}

fn serial_byte(byte: u8) {
    unsafe {
        for _ in 0..100_000 {
            if (core::ptr::read_volatile(0x3fdu16 as *const u8) & 0x20) != 0 {
                asm!("out dx, al", in("dx") 0x3f8u16, in("al") byte);
                return;
            }
        }
    }
}

fn serial_text(text: &[u8]) {
    for &byte in text {
        serial_byte(byte)
    }
}

#[cfg(bios)]
mod bios {
    use super::*;
    core::arch::global_asm!(
        ".section .multiboot, \"a\"",
        ".align 8",
        "mb_header:",
        ".long 0xe85250d6",
        ".long 0",
        ".long mb_header_end - mb_header",
        ".long -(0xe85250d6 + 0 + (mb_header_end - mb_header))",
        ".short 0",
        ".short 0",
        ".long 8",
        "mb_header_end:",
        ".text",
        ".global _start",
        "_start:",
        "cld",
        "push ebx",
        "call rust_start",
        "1: hlt",
        "jmp 1b",
    );
    #[repr(C)]
    struct Tag {
        kind: u32,
        size: u32,
    }
    #[repr(C)]
    struct MemoryMapTag {
        kind: u32,
        size: u32,
        entry_size: u32,
        _entry_version: u32,
    }
    #[repr(C)]
    struct MemoryEntry {
        base: u64,
        length: u64,
        kind: u32,
        _reserved: u32,
    }
    unsafe fn text_at(row: usize, text: &[u8]) {
        let video = 0xb8000usize as *mut u16;
        for (column, &byte) in text.iter().enumerate() {
            unsafe { video.add(row * 80 + column).write_volatile(0x0700 | byte as u16) };
        }
    }
    unsafe fn test_range(base: u64, length: u64) -> bool {
        let start = base.max(MIN_TEST_ADDRESS).next_multiple_of(PAGE_SIZE);
        let end = base.saturating_add(length).min(0x1_0000_0000);
        let mut address = start;
        while address.saturating_add(4) <= end {
            let pointer = address as *mut u32;
            unsafe { pointer.write_volatile(0xa5a5_a5a5) };
            if unsafe { pointer.read_volatile() } != 0xa5a5_a5a5 {
                return false;
            }
            unsafe { pointer.write_volatile(address as u32 ^ 0x5a5a_5a5a) };
            if unsafe { pointer.read_volatile() } != address as u32 ^ 0x5a5a_5a5a {
                return false;
            }
            address += PAGE_SIZE;
        }
        true
    }
    #[unsafe(no_mangle)]
    extern "C" fn rust_start(info: *const u8) -> ! {
        unsafe { text_at(0, b"Black Fox Memory Test") };
        serial_text(b"Black Fox Memory Test\r\n");
        let total_size = unsafe { (info as *const u32).read() } as usize;
        let mut offset = 8usize;
        let mut passed = true;
        while offset < total_size {
            let tag = unsafe { &*(info.add(offset) as *const Tag) };
            if tag.kind == 6 {
                let map = unsafe { &*(info.add(offset) as *const MemoryMapTag) };
                let mut entry_offset = offset + 16;
                while entry_offset + map.entry_size as usize <= offset + tag.size as usize {
                    let entry = unsafe { &*(info.add(entry_offset) as *const MemoryEntry) };
                    if entry.kind == 1 {
                        passed &= unsafe { test_range(entry.base, entry.length) };
                    }
                    entry_offset += map.entry_size as usize;
                }
            }
            if tag.kind == 0 {
                break;
            }
            offset += (tag.size as usize + 7) & !7;
        }
        if passed {
            unsafe { text_at(2, b"PASS: available memory patterns verified") };
            serial_text(b"PASS: available memory patterns verified\r\n");
        } else {
            unsafe { text_at(2, b"FAIL: memory mismatch detected") };
            serial_text(b"FAIL: memory mismatch detected\r\n");
        }
        halt()
    }
}

#[cfg(uefi)]
mod uefi {
    use super::*;
    type Handle = usize;
    type Status = usize;
    type AllocatePool = extern "efiapi" fn(u32, usize, *mut *mut u8) -> Status;
    type ExitBootServices = extern "efiapi" fn(Handle, usize) -> Status;
    #[repr(C)]
    struct SystemTable {
        _header: [u8; 24],
        _firmware_vendor: *mut u16,
        _firmware_revision: u32,
        _padding: u32,
        _console_in_handle: Handle,
        con_in: *mut TextInput,
        _console_out_handle: Handle,
        con_out: *mut TextOutput,
        _stderr_handle: Handle,
        _stderr: *mut u8,
        _runtime: *mut u8,
        boot_services: *mut BootServices,
    }
    #[repr(C)]
    struct TextOutput {
        _reset: usize,
        output_string: extern "efiapi" fn(*mut TextOutput, *const u16) -> Status,
    }
    #[repr(C)]
    struct TextInput {
        _reset: usize,
        read_key_stroke: extern "efiapi" fn(*mut TextInput, *mut InputKey) -> Status,
    }
    #[repr(C)]
    struct InputKey {
        _scan_code: u16,
        unicode: u16,
    }
    #[repr(C)]
    struct BootServices {
        _header: [u8; 24],
        _raise_tpl: usize,
        _restore_tpl: usize,
        _allocate_pages: usize,
        _free_pages: usize,
        get_memory_map: extern "efiapi" fn(*mut usize, *mut u8, *mut usize, *mut usize, *mut u32) -> Status,
        allocate_pool: AllocatePool,
        _free_pool: usize,
        _reserved: [usize; 18],
        exit_boot_services: ExitBootServices,
    }
    #[repr(C)]
    struct MemoryDescriptor {
        kind: u32,
        _padding: u32,
        physical_start: u64,
        _virtual_start: u64,
        pages: u64,
        _attribute: u64,
    }
    fn output(table: *mut SystemTable, text: &[u16]) {
        let con_out = unsafe { (*table).con_out };
        unsafe { ((*con_out).output_string)(con_out, text.as_ptr()) };
    }
    fn read_key(table: *mut SystemTable) -> u16 {
        let input = unsafe { (*table).con_in };
        let mut pressed = InputKey { _scan_code: 0, unicode: 0 };
        loop {
            if unsafe { ((*input).read_key_stroke)(input, &mut pressed) } == 0 {
                return pressed.unicode;
            }
        }
    }
    fn output_ascii(table: *mut SystemTable, text: &[u8]) {
        let mut wide = [0u16; 256];
        let count = text.len().min(wide.len() - 1);
        for index in 0..count {
            wide[index] = text[index] as u16;
        }
        output(table, &wide);
    }
    unsafe fn test_range(base: u64, length: u64) -> bool {
        let start = base.max(MIN_TEST_ADDRESS).next_multiple_of(PAGE_SIZE);
        let end = base.saturating_add(length);
        let mut address = start;
        while address.saturating_add(4) <= end {
            let pointer = address as *mut u32;
            pointer.write_volatile(0xa5a5_a5a5);
            if pointer.read_volatile() != 0xa5a5_a5a5 { return false; }
            pointer.write_volatile(address as u32 ^ 0x5a5a_5a5a);
            if pointer.read_volatile() != address as u32 ^ 0x5a5a_5a5a { return false; }
            address += PAGE_SIZE;
        }
        true
    }
    #[unsafe(no_mangle)]
    extern "efiapi" fn efi_main(_handle: Handle, table: *mut SystemTable) -> Status {
        output_ascii(table, b"Black Fox Memory Test\r\n\r\n  Memory graph\r\n  Available [####################]\r\n  Reserved  [....................]\r\n\r\n  [S] Start     [E] Exit\r\n");
        serial_text(b"Black Fox Memory Test\r\n");
        let choice = read_key(table);
        if choice == b'e' as u16 || choice == b'E' as u16 {
            return 0;
        }
        if choice != b's' as u16 && choice != b'S' as u16 {
            return 0;
        }
        output_ascii(table, b"\r\nBlack Fox Memory Test\r\n\r\n  Testing [....................]\r\n");
        let services = unsafe { &mut *(*table).boot_services };
        let mut map_size = 0usize;
        let mut key = 0usize;
        let mut descriptor_size = 0usize;
        let mut descriptor_version = 0u32;
        let _ = (services.get_memory_map)(&mut map_size, core::ptr::null_mut(), &mut key, &mut descriptor_size, &mut descriptor_version);
        map_size += descriptor_size * 2;
        let mut map = core::ptr::null_mut();
        if (services.allocate_pool)(2, map_size, &mut map) != 0 { halt() }
        if (services.get_memory_map)(&mut map_size, map, &mut key, &mut descriptor_size, &mut descriptor_version) != 0 { halt() }
        let mut passed = true;
        let mut offset = 0usize;
        while offset + core::mem::size_of::<MemoryDescriptor>() <= map_size {
            let entry = unsafe { &*(map.add(offset) as *const MemoryDescriptor) };
            if entry.kind == 7 { passed &= unsafe { test_range(entry.physical_start, entry.pages * 4096) }; }
            offset += descriptor_size;
        }
        if passed {
            output_ascii(table, b"\r\n  Testing [####################]\r\n  PASS: available memory verified\r\n\r\n  Press any key to exit.\r\n");
            serial_text(b"PASS: available memory patterns verified\r\n");
        } else {
            output_ascii(table, b"\r\n  FAIL: memory mismatch detected\r\n\r\n  Press any key to exit.\r\n");
            serial_text(b"FAIL: memory mismatch detected\r\n");
        }
        let _ = read_key(table);
        0
    }
}