#!/bin/sh
set -e

# ── Coolify Auto-Deploy Entrypoint ──
# Wraps the default docker-entrypoint.sh with auto-onboarding
# on first boot so Coolify deployments are fully hands-off.

PAPERCLIP_HOME="${PAPERCLIP_HOME:-/paperclip}"
CONFIG_FILE="$PAPERCLIP_HOME/instances/default/config.json"

# Auto-onboard if no config exists yet (first boot)
if [ "${PAPERCLIP_AUTO_ONBOARD:-false}" = "true" ] && [ ! -f "$CONFIG_FILE" ]; then
    echo "╔══════════════════════════════════════════════╗"
    echo "║  Paperclip: First boot — auto-onboarding... ║"
    echo "╚══════════════════════════════════════════════╝"

    # Run onboard as the node user with quickstart defaults
    if [ "$(id -u)" -eq 0 ]; then
        gosu node pnpm paperclipai onboard --yes 2>&1 || true
    else
        pnpm paperclipai onboard --yes 2>&1 || true
    fi

    echo "Auto-onboard complete. Starting server..."
fi

# Hand off to the original entrypoint
exec docker-entrypoint.sh "$@"
