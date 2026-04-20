# fig-lite Codebase Summary

## Overview

**fig-lite** is a Linux-focused fork of the Amazon Q Developer CLI (formerly Fig), stripped down to the shell autocomplete surface. All chat / translate / Amazon-cloud assistant features have been removed. The product is a desktop app (Tauri/tao/wry AppImage) plus a figterm PTY shim plus a CLI, together delivering spec-driven autocomplete in the terminal.

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

### Autocomplete API path
- `fig_api_client` — Thin wrapper over `amzn-codewhisperer-client` exposing `generate_completions`, customization/profile listing, and telemetry-event upload. Chat/streaming types were removed in the fig-lite fork.
- `amzn-codewhisperer-client` — Smithy-generated AWS SDK (CodeWhisperer). Used for the completions RPC. Many chat/agentic operations are unused but not yet pruned from the generated code.
- `amzn-consolas-client` — Secondary completion backend.
- `amzn-toolkit-telemetry-client` / `aws-toolkit-telemetry-definitions` — Metric posting.

### Auth
- `fig_auth` — Builder ID + PKCE OAuth flow; secret store backed by the system keyring.

### Settings & state
- `fig_settings` — SQLite-backed settings/state with migrations (`r2d2`/`rusqlite`).
- `fig_os_shim` — OS abstraction layer used by tests.

### Telemetry
- `fig_telemetry_core` — Event type definitions + global emitter trait.
- `fig_telemetry` — Runtime emitter that dispatches to CodeWhisperer and the toolkit metrics endpoint.

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
- `fig_aws_common` — Shared AWS SDK glue.
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

Unused operations still present inside `amzn-codewhisperer-client` (task-assist, transformation, code-analysis, code-fix, agentic chat, etc.) have been left in place because the crate is Smithy-generated; a targeted prune is tracked separately.
