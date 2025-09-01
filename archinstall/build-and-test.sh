#!/bin/bash

if [ -z "$1" ]
then
	echo "Need to define a output folder for the archiso:"
	echo "Example (build and run):"
	echo "  ./test.sh ./archiso true"
	echo "Example (skip building and run ISO as given path):"
	echo "  ./test.sh ./archiso"
	exit 1
fi

REPO="https://github.com/Torxed/archinstall.git"
ARCHISO_FOLDER=$1
REBUILD=$2
BRANCH="master"

function get_password() {
    # Loop until the passwords match
    while true; do
      # Prompt user for the first password
      echo -n "Enter your password: " >&2
      read -s password1
      echo >&2

      if [ -z "$password1" ]; then
        echo "Password must not be empty.  Please try again." >&2
        continue
      fi

      # Prompt user for the second password
      echo -n "Confirm your password: " >&2
      read -s password2
      echo >&2

      # Check if passwords match
      if [ "$password1" == "$password2" ]; then
        echo "Passwords match!" >&2
        break  # Exit the loop if passwords match
      else
        echo "Passwords do not match. Please try again." >&2
      fi
    done

    mkpasswd -m yescrypt "$password1"
}

if [ $REBUILD ]
then
    # Prompt with default = $USER
    read -p "Enter name for arch super user [${USER}]: " USERNAME
    # If empty, fall back to $USER
    USERNAME=${USERNAME:-$USER}
    PASSWORD="$(get_password)"

	echo "Making a clean build!"
	`rm -rf "${ARCHISO_FOLDER}" 2>/dev/null` || (
		echo "Could not delete protected folder:";
		echo "-> ${ARCHISO_FOLDER}";
		echo "Running as sudo.";
		sudo rm -rf "${ARCHISO_FOLDER}"
	)

	mkdir -p "${ARCHISO_FOLDER}"
	cp -r /usr/share/archiso/configs/releng/* "${ARCHISO_FOLDER}/"

	git clone "${REPO}" "${ARCHISO_FOLDER}/airootfs/root/archinstall-git"
	(cd "${ARCHISO_FOLDER}/airootfs/root/archinstall-git"; git checkout "${BRANCH}" )

    cat <<\EOF >> "${ARCHISO_FOLDER}/packages.x86_64"
git
networkmanager
EOF

	cp autorun.sh "${ARCHISO_FOLDER}/airootfs/root/.zprofile"
    jq -n --arg user "$USERNAME" --arg password "$PASSWORD" \
        '{users: [{enc_password: $password, groups: [], sudo: true, username: $user}]}' \
        > "${ARCHISO_FOLDER}/airootfs/root/user_credentials.json"
    jq --arg user "$USERNAME" --arg hyprconf "$(base64 -w 0 ../dot_config/hypr/hyprland.conf)" \
        '.custom_commands += ["usermod -s $(which zsh) \($user)", "echo sh -c \"$(curl -fsLS https://github.com/olidacombe/dotfiles/raw/main/bootstrap.sh)\" > /home/\($user)/.zshrc", "base64 -d <<< \($hyprconf) > /usr/share/hypr/hyprland.conf"]' \
        < user_configuration.json \
        > "${ARCHISO_FOLDER}/airootfs/root/user_configuration.json"

	( cd "${ARCHISO_FOLDER}/"; sudo mkarchiso -v -w work/ -o out/ ./; )
fi

if [ ! -f "./test.qcow2" ];
then
	qemu-img create -f qcow2 ./test.qcow2 200G
fi

sudo -E qemu-system-x86_64 \
        -cpu host \
        -enable-kvm \
        -machine q35,accel=kvm \
        -device intel-iommu \
        -m 8192 \
        -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/x64/OVMF_CODE.4m.fd  \
        -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/x64/OVMF_VARS.4m.fd \
        -device virtio-scsi-pci,bus=pcie.0,id=scsi0 \
            -device scsi-hd,drive=hdd0,bus=scsi0.0,id=scsi0.0,bootindex=2 \
                -drive file=./test.qcow2,if=none,format=qcow2,discard=unmap,aio=native,cache=none,id=hdd0 \
        -device virtio-scsi-pci,bus=pcie.0,id=scsi1 \
            -device scsi-cd,drive=cdrom0,bus=scsi1.0,bootindex=1 \
                -drive file=$(ls -t $ARCHISO_FOLDER/out/*.iso | head -n 1),media=cdrom,if=none,format=raw,cache=none,id=cdrom0
