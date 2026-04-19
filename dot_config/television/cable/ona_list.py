#!/usr/bin/env python3
"""Television source script for listing Ona environments."""

import json
import sys

ICONS = {
    "ENVIRONMENT_PHASE_RUNNING": "▶ running",
    "ENVIRONMENT_PHASE_STOPPED": "■ stopped",
    "ENVIRONMENT_PHASE_STARTING": "◷ starting",
    "ENVIRONMENT_PHASE_STOPPING": "◷ stopping",
    "ENVIRONMENT_PHASE_CREATING": "◷ creating",
    "ENVIRONMENT_PHASE_DELETING": "◷ deleting",
}

for e in json.load(sys.stdin):
    eid = e["id"]
    phase = e.get("status", {}).get("phase", "unknown")

    git = (
        e.get("spec", {})
        .get("content", {})
        .get("initializer", {})
        .get("specs", [{}])[0]
        .get("git", {})
    )
    name = git.get("checkoutLocation") or e.get("name") or eid[:12]
    branch = e.get("status", {}).get("content", {}).get("git", {}).get("branch", "")
    remote = git.get("remoteUri", "")
    repo = remote.split("/")[-1].replace(".git", "") if remote else ""
    label = repo or name
    if branch and branch not in ("main", "master"):
        label += " @ " + branch

    status = ICONS.get(phase, "? " + phase.replace("ENVIRONMENT_PHASE_", "").lower())
    print(f"{eid}\t{label}\t{status}")
