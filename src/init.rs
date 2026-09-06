use liblk::*;
use nix::mount::MsFlags;
use nix::unistd::chdir;
use std::env;
use std::fs::OpenOptions;
use std::io::Write;
use std::os::unix::process::CommandExt;
use std::path::Path;
use std::process::{Command, Stdio};

const CYAN_BOLD: &str = "\x1b[1;36m";
const RESET: &str = "\x1b[0m";

fn mount_options(flags: MsFlags) -> String {
    let mut options = Vec::new();
    if flags.contains(MsFlags::MS_NOSUID) {
        options.push("nosuid");
    }
    if flags.contains(MsFlags::MS_NODEV) {
        options.push("nodev");
    }
    if flags.contains(MsFlags::MS_NOEXEC) {
        options.push("noexec");
    }
    options.join(",")
}

fn mount_fs(source: &str, target: &str, fstype: &str, flags: MsFlags) {
    let path = Path::new(target);
    if !path.exists() {
        if let Err(e) = fs::lkcreate(path) {
            ui::error(&format!(
                "Failed to create {} directory! Err: {}",
                target, e
            ));
            std::thread::sleep(std::time::Duration::from_secs(3));
            clear();
        }
    }
    let options = mount_options(flags);
    if let Err(e) = fs::lkmount(source, path, fstype, &options) {
        ui::error(&format!(
            "Failed to mount {} on {}! Err: {}",
            fstype, target, e
        ));
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
    println!(
        "                    BLACK FOX {}",
        env!("CARGO_PKG_VERSION")
    );
    println!("");
    println!("      \"A small recovery shell for emergency maintenance\"");
    println!("");
    print!("{RESET}");
}

fn banner() {
    print!("{CYAN_BOLD}");
    println!("");
    println!("                    BLACK FOX {}", env!("CARGO_PKG_VERSION"));
    println!("");
    println!("Black Fox: \"What should we fix today, admin?\"");
    println!("");
    println!("> IMPORTANT NOTE: This is a minimal recovery shell. Only critical commands are available!");
    println!("> Help: Type \"lk -w\" to check if a command exists.");
    println!("");
    print!("{RESET}");
}

fn active_console() -> Option<&'static str> {
    let cmdline = std::fs::read_to_string("/proc/cmdline").ok()?;
    let device = if cmdline.contains("console=tty0") {
        "/dev/tty0"
    } else if cmdline.contains("console=ttyS0") {
        "/dev/ttyS0"
    } else {
        return None;
    };
    OpenOptions::new().read(true).write(true).open(device).ok()?;
    Some(device)
}

fn main() {
    bootup();
    std::thread::sleep(std::time::Duration::from_secs(3));
    clear();
    mount_fs("proc", "/proc", "proc", MsFlags::empty());
    mount_fs("sysfs", "/sys", "sysfs", MsFlags::empty());
    mount_fs("devtmpfs", "/dev", "devtmpfs", MsFlags::empty());
    mount_fs(
        "tmpfs",
        "/tmp",
        "tmpfs",
        MsFlags::MS_NOSUID | MsFlags::MS_NODEV,
    );
    let _ = fs::lkcreate(Path::new("/admin"));
    if let Err(e) = chdir("/admin") {
        ui::error(&format!(
            "Failed to change directory to \"/admin\"! Err: {}",
            e
        ));
        std::thread::sleep(std::time::Duration::from_secs(3));
        clear();
    }
    unsafe {
        env::set_var("HOME", "/admin");
        env::set_var("PWD", "/admin");
        env::set_var("PATH", "/bin:/sbin:/bin/others:/sbin/others");
        env::set_var("TERM", "linux");
    }
    let _ = fs::lkremove(Path::new("/root"));
    banner();
    let mut shell = Command::new("/bin/busybox");
    shell
        .args(["setsid", "-c", "sh"])
        .env("PS1", "\x1b[1;36m[ blackfox@admin ] #\x1b[0m ")
        .current_dir("/admin");
    if let Some(console) = active_console() {
        let open_console = || {
            OpenOptions::new()
                .read(true)
                .write(true)
                .open(console)
                .map(Stdio::from)
        };
        shell
            .stdin(open_console().unwrap_or_else(|_| Stdio::inherit()))
            .stdout(open_console().unwrap_or_else(|_| Stdio::inherit()))
            .stderr(open_console().unwrap_or_else(|_| Stdio::inherit()));
    }
    let err = shell.exec();
    ui::error(&format!(
        "FATAL: Failed to execute BusyBox shell! Err: {}",
        err
    ));
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
