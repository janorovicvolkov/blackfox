use nix::sys::reboot::{reboot, RebootMode};
use nix::unistd::sync;
use std::env;
use std::io;
use std::path::Path;

fn reboot_mode(command: &str) -> Option<RebootMode> {
    match Path::new(command).file_name()?.to_str()? {
        "reboot" => Some(RebootMode::RB_AUTOBOOT),
        "poweroff" | "shutdown" => Some(RebootMode::RB_POWER_OFF),
        _ => None,
    }
}

fn main() -> io::Result<()> {
    let command = env::args_os()
        .next()
        .ok_or_else(|| io::Error::new(io::ErrorKind::InvalidInput, "missing command name"))?;
    let command = command.to_string_lossy();
    let mode = reboot_mode(&command).ok_or_else(|| {
        io::Error::new(
            io::ErrorKind::InvalidInput,
            "command must be named reboot, poweroff, or shutdown",
        )
    })?;
    sync();
    reboot(mode)
        .map(|never| match never {})
        .map_err(io::Error::other)
}

#[cfg(test)]
mod tests {
    use super::{reboot_mode, RebootMode};
    #[test]
    fn commands_select_expected_modes() {
        assert_eq!(reboot_mode("/bin/reboot"), Some(RebootMode::RB_AUTOBOOT));
        assert_eq!(reboot_mode("poweroff"), Some(RebootMode::RB_POWER_OFF));
        assert_eq!(reboot_mode("/bin/shutdown"), Some(RebootMode::RB_POWER_OFF));
        assert_eq!(reboot_mode("halt"), None);
    }
}