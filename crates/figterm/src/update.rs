use crossterm::style::Stylize;
use fig_os_shim::{
    Context,
    Os,
};
use fig_settings::keys::UPDATE_AVAILABLE_KEY;
use fig_util::CLI_BINARY_NAME;
use fig_util::manifest::{
    Variant,
    manifest,
};
use semver::Version;

fn current_version() -> Version {
    Version::parse(env!("CARGO_PKG_VERSION")).unwrap()
}

fn print_update_message(context: &Context, version: &Version) {
    let os = context.platform().os();
    let variant = &manifest().variant;
    match (os, variant) {
        (Os::Linux, Variant::Full) => {
            println!(
                "\nA new version of {} is available: {}\n",
                CLI_BINARY_NAME.bold(),
                version.to_string().bold(),
            );
        },
        _ => {
            println!(
                "\nA new version of {} is available: {}\nRun {} to update to the new version\n",
                CLI_BINARY_NAME.bold(),
                version.to_string().bold(),
                format!("{CLI_BINARY_NAME} update").magenta().bold()
            );
        },
    };
}

pub fn check_for_update(_context: &Context) {
    // Patched: always clear any stored update notice and skip update checks.
    fig_settings::state::remove_value(UPDATE_AVAILABLE_KEY).ok();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_current_version() {
        let version = current_version();
        println!("Crate version: {version}");
    }

    #[test]
    fn test_print_update_message() {
        let version = Version::parse("1.2.3").unwrap();
        println!("===");
        print_update_message(&Context::new(), &version);
        println!("===");

        println!("===");
        print_update_message(&Context::builder().with_os(Os::Linux).build_fake(), &version);
        println!("===");
    }
}
