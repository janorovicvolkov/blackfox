use std::env;
use std::os::unix::process::CommandExt;
use std::process::Command;
use std::path::Path;
use std::fs::OpenOptions;
use std::io::Write;
use liblk::*;
use nix::unistd::{chdir, setsid};
use nix::mount::MsFlags;

const CYAN_BOLD: &str = "\x1b[1;36m";
const RESET: &str = "\x1b[0m";

fn mount_fs(source: &str, target: &str, fstype: &str, flags: MsFlags) {
    let path = Path::new(target);
    if let Err(e) = fs::lkcreate(path) {
        ui::error(&format!("Failed to create {} directory! Err: {}", target, e));
        std::thread::sleep(std::time::Duration::from_secs(3));
        clear();
    }
    if let Err(e) = fs::lkmount(source, path, fstype, format!("{:?}", flags).as_str()) {
        ui::error(&format!("Failed to mount {} on {}! Err: {}", fstype, target, e));
        std::thread::sleep(std::time::Duration::from_secs(3));
        clear();
    }
}

fn clear() {
    if let Ok(mut console) = OpenOptions::new().write(true).open("/dev/console") {
        let _ = console.write_all(b"\x1b[H\x1b[2J\x1b[3J");
    }
}

fn bootup() {
    clear();
    print!("{CYAN_BOLD}");
    println!("");
    println!("                    BLACK FOX RECOVERY {}", env!("CARGO_PKG_VERSION"));
    println!("");
    println!("       \"A small recovery shell for emergency maintenance\"");
    println!("");
    print!("{RESET}");
}

fn banner() {
    print!("{CYAN_BOLD}");
    println!("");
    println!("BLACK FOX RECOVERY {}", env!("CARGO_PKG_VERSION"));
    println!("");
    println!("Black Fox: \"What should we fix today, admin?\"");
    println!("");
    println!("> Note: This is a minimal recovery shell. Only a critical commands are available.");
    println!("> Help: Type \"which\" to check if a command exists.");
    println!("");
    print!("{RESET}");
}

fn main() {
    bootup();
    std::thread::sleep(std::time::Duration::from_secs(3));
    clear();
    mount_fs("proc", "/proc", "proc", MsFlags::empty());
    mount_fs("sysfs", "/sys", "sysfs", MsFlags::empty());
    mount_fs("devtmpfs", "/dev", "devtmpfs", MsFlags::empty());
    mount_fs("tmpfs", "/tmp", "tmpfs", MsFlags::MS_NOSUID | MsFlags::MS_NODEV);
    let _ = fs::lkcreate(Path::new("/admin"));
    if let Err(e) = chdir("/admin") {
        ui::error(&format!("Failed to change directory to \"/admin\"! Err: {}", e));
        std::thread::sleep(std::time::Duration::from_secs(3));
        clear();
    }
    unsafe {
        env::set_var("HOME", "/admin");
        env::set_var("PWD", "/admin");
        env::set_var("PATH", "/bin:/sbin:/bin/others:/sbin/others");
        env::set_var("TERM", "linux");
    }
    let _ = Command::new("/bin/busybox")
        .args(["--install", "-s", "/bin"])
        .status();
    let _ = setsid();
    banner();
    let err = Command::new("/bin/busybox")
        .arg("sh")
        .env("PS1", "\x1b[1;36m[ blackfox@admin ] #\x1b[0m ")
        .current_dir("/admin")
        .exec();
    ui::error(&format!("FATAL: Failed to execute bash shell! Err: {}", err));
    ui::error("Halting system to prevent kernel panic!");
    loop {
        clear();
        println!(".");
        println!("..");
        println!("...");
        std::thread::sleep(std::time::Duration::from_secs(2));
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_bootup() {
        super::bootup();
    }
    #[test]
    fn test_banner() {
        super::banner();
    }
    #[test]
    fn test_clear() {
        super::clear();
    }
    #[test]
    fn test_loop() {
        loop {
            super::clear();
            println!(".");
            println!("..");
            println!("...");
            std::thread::sleep(std::time::Duration::from_secs(2));
            break;
        }
    }
}