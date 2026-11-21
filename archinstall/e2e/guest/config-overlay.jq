# Test-only changes applied (inside the live ISO) to the user_configuration.json
# baked into the ISO. Keep this minimal: everything here is a divergence from
# what a real install gets.
#
# Inputs: $user (from the baked creds), $keys (authorized_keys for $user),
#         $disk (device path), $disk_mib (its size in MiB).

def size($mib): {value: $mib, unit: "MiB", sector_size: {value: 512, unit: "B"}};
def part($id; $start; $len; $fs; $mnt; $flags): {
    obj_id: $id, status: "create", type: "primary",
    start: size($start), size: size($len),
    fs_type: $fs, mountpoint: $mnt, mount_options: [], flags: $flags,
    btrfs: [], dev_path: null
};

# 1. No disk selection prompt: wipe the VM disk with a fixed ESP + ext4 layout.
.disk_config = {
    config_type: "default_layout",
    device_modifications: [{
        device: $disk,
        wipe: true,
        partitions: [
            part("e2e-esp";  1;    1024;                   "fat32"; "/boot"; ["boot", "esp"]),
            part("e2e-root"; 1025; ($disk_mib - 1025 - 2); "ext4";  "/";     [])
        ]
    }]
}

# 2. Remote access for the harness (test-only openssh).
| .packages += ["openssh"]
| .services += ["sshd"]

# 3. Install the harness key for the user. Appended after the baked custom
#    commands, so it runs after their chown of /home/$user.
| .custom_commands += [
    "install -d -m 700 -o \($user) -g \($user) /home/\($user)/.ssh && printf '%s\\n' \(($keys | @sh)) > /home/\($user)/.ssh/authorized_keys && chown \($user):\($user) /home/\($user)/.ssh/authorized_keys && chmod 600 /home/\($user)/.ssh/authorized_keys"
]
