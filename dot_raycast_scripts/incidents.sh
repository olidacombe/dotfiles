#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Incidents
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ❗
# @raycast.packageName grafana
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Open incidents for past week
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

export RAYCAST_VARS="${HOME}/.config/profile.d/raycast"

if [ -f "${RAYCAST_VARS}" ]; then
    source "${RAYCAST_VARS}"
fi

export DFMT="+%Y-%m-%dT00:00:00Z"
export NOWFMT="+%Y-%m-%dT%H:%M:%SZ"
export GRAFANA_BASE_DOMAIN="${GRAFANA_BASE_DOMAIN:-"grafana.net"}"

function urlencode() {
    sed -e 's/:/%3A/g;s/,/%2C/g' <<< "$1"
}

open "https://${GRAFANA_BASE_DOMAIN}/a/grafana-incident-app/incidents?q=$(urlencode "declared:$(date -v"-7d" "$DFMT"),$(date "$NOWFMT")")"
