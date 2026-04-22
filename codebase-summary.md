# fig-lite Codebase Summary

## Overview

**fig-lite** is a Linux-focused fork of the Amazon Q Developer CLI (formerly Fig), stripped down to the shell autocomplete surface. All chat / translate / AI / auth / Amazon-cloud assistant features have been removed. The product is a desktop app (Tauri/tao/wry AppImage) plus a figterm PTY shim plus a CLI, together delivering spec-driven autocomplete in the terminal.

## Key Components

1. **q_cli** (`crates/q_cli`) — CLI entry point. Dispatches `init`, `internal`, `completion`, `hook`, diagnostics, install, settings.
2. **fig_desktop** (`crates/fig_desktop`) — Tauri-style desktop shell (tao + wry) hosting the autocomplete popup window. Bundled as an AppImage on Linux.
3. **figterm** (`crates/figterm`) — PTY shim built on `alacritty_terminal` that sits between the user's shell and the real terminal, parsing the edit buffer to drive suggestions.
4. **Web apps** (`packages/`) — React/Vite dashboard (`packages/dashboard-app`) and autocomplete UI; built via pnpm + turborepo.
5. **IDE integrations** (`crates/fig_integrations`, `extensions/`) — VSCode, JetBrains, GNOME shell extension IPC (Unix socket + gdbus/zbus).

## Project Structure

- `crates/` — Internal Rust crates (see below)
- `packages/` — pnpm workspace with dashboard + autocomplete UI
- `proto/` — Protocol buffer IPC messages
- `extensions/` — IDE extensions
- `build-scripts/` — Python build orchestration (`main.py`, `build.py`, `rust.py`, `const.py`, `util.py`, `signing.py`)
- `build-config/` — buildspec YAML for CI
- `bundle/` — Linux AppImage bundling assets
- `cloned_spec/` — Local mirror of the withfig/autocomplete specs (replaces the AWS CDN fetch)
- `tests/` — Integration tests

## Rust workspace

### Settings & state
- `fig_settings` — SQLite-backed settings/state with migrations (`r2d2`/`rusqlite`).
- `fig_os_shim` — OS abstraction layer used by tests.

### IPC
- `fig_proto` — Protobuf message definitions.
- `fig_ipc` — Unix-socket client/server helpers.
- `fig_remote_ipc` — Cross-host IPC for SSH scenarios.
- `fig_desktop_api` — Bridge exposing Rust functionality to the webview side.

### Install / integrations
- `fig_install` — Self-update + shell integration installer.
- `fig_integrations` — Per-shell (bash/zsh/fish) and per-IDE (VSCode/JetBrains/GNOME) integration management.

### Support
- `fig_util` — Shared helpers (directories, terminal/shell detection, system info).
- `fig_log` — Tracing setup.
- `fig_request` — HTTP client wrapper.
- `alacritty_terminal` — Vendored terminal-grid parser used by figterm.

## Build

- **Docker-based reproducible build:** `build.sh` → `Dockerfile.build` → `build-scripts/main.py`.
- **Cargo incremental caching** keyed off the git commit date (`AMAZON_Q_BUILD_DATETIME`) so rebuilds at a stable commit reuse fingerprints.
- **Tauri bundling** is split from the cargo build; AppImage is skipped when the existing bundle is newer than the freshly-built binary.

## Removed features (relative to upstream)

| Feature | Status |
|---|---|
| `q chat` / qchat binary | Removed (Rust code + dashboard UI) |
| `q translate` | Removed end-to-end (`arboard`, `region_check`, `wayland` feature, `TranslationActioned` telemetry) |
| Chat streaming clients (`amzn-*-streaming-client`) | Crates deleted from workspace |
| `semantic_search_client` | Removed as orphan |
| Telemetry | Removed end-to-end (core crate, calls, dashboard toggles) |
| Inline shell completion (AI ghost-text) | Removed end-to-end (CLI `q inline`, figterm inline module + IPC, dashboard page, customization/profile pickers) |
| `fig_api_client` + `amzn-codewhisperer-client` + `amzn-consolas-client` | Crates deleted — no longer referenced after inline removal |
| Auth (`q login`/`logout`/`whoami`, Builder ID + PKCE, Identity Center, auth watcher, tray login, IPC `Auth*` messages, Midway cookie flow) | Removed end-to-end; `fig_auth` + `fig_aws_common` crates deleted, AWS SDK stack dropped from Cargo.lock |
