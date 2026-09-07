use liblk::*;
use nix::mount::MsFlags;
use nix::unistd::chdir;
use std::env;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::Path;
use std::process::Command;

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

fn print(msg: &str) {
    if let Ok(mut console) = OpenOptions::new().write(true).open("/dev/console") {
        let formatted = format!("\x1b[1;36m{}\x1b[0m\n", msg);
        let _ = console.write_all(formatted.as_bytes());
    }
}

fn space() {
    if let Ok(mut console) = OpenOptions::new().write(true).open("/dev/console") {
        let _ = console.write_all(b"\n");
    }
}

fn bootup() {
    clear();
    space();
    print(&format!("                        BLACK FOX {}", env!("CARGO_PKG_VERSION")));
    space();
    print("      \"A small recovery shell for emergency maintenance\"");
    space();
}

fn banner() {
    space();
    print(&format!("                        BLACK FOX {}", env!("CARGO_PKG_VERSION")));
    space();
    print("Black Fox: \"What should we fix today, admin?\"");
    space();
    space();
    print("> IMPORTANT NOTE: This is a minimal recovery shell. Only critical commands are available!");
    print("> Help: Type \"lk -w\" to check if a command exists.");
    space();
}

fn run_getty() -> ! {
    loop {
        let result = Command::new("/bin/agetty")
            .args([
                "--noclear",
                "--skip-login",
                "--login-program",
                "/bin/sh",
                "tty1",
                "linux",
            ])
            .env("PS1", "\x1b[1;36m[ blackfox@admin ] #\x1b[0m ")
            .current_dir("/admin")
            .status();
        if let Err(error) = result {
            ui::error(&format!(
                "FATAL: Failed to execute agetty on tty1! Err: {}",
                error
            ));
        }
        std::thread::sleep(std::time::Duration::from_secs(1));
    }
}

fn main() {
    mount_fs("proc", "/proc", "proc", MsFlags::empty());
    mount_fs("sysfs", "/sys", "sysfs", MsFlags::empty());
    mount_fs("devtmpfs", "/dev", "devtmpfs", MsFlags::empty());
    mount_fs("tmpfs", "/tmp", "tmpfs", MsFlags::MS_NOSUID | MsFlags::MS_NODEV);
    bootup();
    std::thread::sleep(std::time::Duration::from_secs(3));
    clear();
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
    run_getty();
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
    fn test_space() {
        super::space();
    }
    #[test]
    fn test_print() {
        super::print("Test message");
    }
    #[test]
    fn test_mount_options() {
        use nix::mount::MsFlags;
        let flags = MsFlags::MS_NOSUID | MsFlags::MS_NODEV | MsFlags::MS_NOEXEC;
        let options = super::mount_options(flags);
        assert_eq!(options, "nosuid,nodev,noexec");
    }
}
