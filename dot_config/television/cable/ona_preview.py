#!/usr/bin/env python3
"""Television preview script for Ona environment details."""

import json
import sys

ICONS = {
    "ENVIRONMENT_PHASE_RUNNING": "▶ Running",
    "ENVIRONMENT_PHASE_STOPPED": "■ Stopped",
    "ENVIRONMENT_PHASE_STARTING": "◷ Starting",
    "ENVIRONMENT_PHASE_STOPPING": "◷ Stopping",
    "ENVIRONMENT_PHASE_CREATING": "◷ Creating",
    "ENVIRONMENT_PHASE_DELETING": "◷ Deleting",
}

data = json.load(sys.stdin)
e = data[0] if isinstance(data, list) else data

phase = e.get("status", {}).get("phase", "unknown")
status = ICONS.get(phase, phase.replace("ENVIRONMENT_PHASE_", ""))

git_spec = (
    e.get("spec", {})
    .get("content", {})
    .get("initializer", {})
    .get("specs", [{}])[0]
    .get("git", {})
)
git_status = e.get("status", {}).get("content", {}).get("git", {})
urls = e.get("status", {}).get("environmentUrls", {})
meta = e.get("metadata", {})
dc = e.get("status", {}).get("devcontainer", {})
ports_spec = e.get("spec", {}).get("ports", [])
timeout = e.get("spec", {}).get("timeout", {})

repo = git_spec.get("remoteUri", "")
branch = git_status.get("branch", "")
commit = git_status.get("latestCommit", "")[:12]
created = meta.get("createdAt", "")[:19].replace("T", " ")
started = meta.get("lastStartedAt", "")[:19].replace("T", " ")
workspace = e.get("status", {}).get("content", {}).get("contentLocationInMachine", "")
dc_phase = dc.get("phase", "").replace("PHASE_", "")
dc_image = e.get("spec", {}).get("devcontainer", {}).get("defaultDevcontainerImage", "")
ssh_url = urls.get("ssh", {}).get("url", "")
ops_url = urls.get("ops", "")
dc_sync = dc.get("devcontainerconfigInSync")

failures = e.get("status", {}).get("failureMessage", [])
af_fail = e.get("status", {}).get("automationsFile", {}).get("failureMessage", "")

env_name = e.get("name", "")
if env_name:
    print(f"  Name:        {env_name}")
print(f"  Status:      {status}")
print(f"  ID:          {e['id']}")
print()
print(f"  Repository:  {repo}")
print(f"  Branch:      {branch}")
if commit:
    print(f"  Commit:      {commit}")
print(f"  Workspace:   {workspace}")
print()
print(f"  Container:   {dc_phase}")
if dc_image:
    img = dc_image.split("/")[-1] if "/" in dc_image else dc_image
    print(f"  Image:       {img}")
if dc_sync is not None:
    sync_label = "yes" if dc_sync else "no"
    print(f"  Config sync: {sync_label}")
print()
if ports_spec:
    print("  Ports:")
    for p in ports_spec:
        name = p.get("name", "")
        port = p.get("port", "")
        print(f"    {port}  {name}")
    print()
print(f"  Created:     {created}")
if started:
    print(f"  Started:     {started}")
if timeout.get("disconnected"):
    raw = timeout["disconnected"].replace("s", "")
    try:
        mins = int(raw) // 60
        print(f"  Timeout:     {mins}m (disconnect)")
    except ValueError:
        print(f"  Timeout:     {timeout['disconnected']}")
print()
if ssh_url:
    print(f"  SSH:         {ssh_url}")
if ops_url:
    print(f"  Dashboard:   {ops_url}")
print()

warnings = set()
if af_fail:
    warnings.add(af_fail)
if failures:
    for f in failures:
        msg = f if isinstance(f, str) else json.dumps(f)
        warnings.add(msg)
for w in sorted(warnings):
    print(f"  ⚠ {w}")
