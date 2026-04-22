use fig_os_shim::Context;
use fig_settings::keys::UPDATE_AVAILABLE_KEY;

pub fn check_for_update(_context: &Context) {
    // Patched: always clear any stored update notice and skip update checks.
    fig_settings::state::remove_value(UPDATE_AVAILABLE_KEY).ok();
}
