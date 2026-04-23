import pathlib


APP_NAME = "Bay"
CLI_BINARY_NAME = "bay"
CLI_BINARY_NAME_MINIMAL = "bay-minimal"
PTY_BINARY_NAME = "bayterm"
DESKTOP_BINARY_NAME = "bay-desktop"
URL_SCHEMA = "bay"
TAURI_PRODUCT_NAME = "bay-desktop"
LINUX_PACKAGE_NAME = "bay"

# macos specific
MACOS_BUNDLE_ID = "org.siriuscrain.bay"
DMG_NAME = APP_NAME

# Linux specific
LINUX_ARCHIVE_NAME = "bay"
LINUX_GNOME_EXTENSION_UUID = "bay-gnome-integration@siriuscrain.org"

# cargo packages
CLI_PACKAGE_NAME = "q_cli"
PTY_PACKAGE_NAME = "figterm"
DESKTOP_PACKAGE_NAME = "fig_desktop"
DESKTOP_FUZZ_PACKAGE_NAME = "fig_desktop-fuzz"

DESKTOP_PACKAGE_PATH = pathlib.Path("crates", "fig_desktop")

# AMZN Mobile LLC
APPLE_TEAM_ID = "94KV3E626L"
