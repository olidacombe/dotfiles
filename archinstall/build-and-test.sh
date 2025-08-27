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

if [ $REBUILD ]
then
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

	echo "git" >> "${ARCHISO_FOLDER}/packages.x86_64"
	echo "python" >> "${ARCHISO_FOLDER}/packages.x86_64"
	echo "python-setuptools" >> "${ARCHISO_FOLDER}/packages.x86_64"

# 	cat <<\EOF >> "${ARCHISO_FOLDER}/airootfs/root/.zprofile"
# [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && sh -c "cd /root/archinstall-git; git config --global pull.rebase false; git pull; cp examples/guided.py ./; python guided.py"
# EOF
	cat <<\EOF >> "${ARCHISO_FOLDER}/airootfs/root/.zprofile"
        echo YO YO YO WHASSSSUUUUUUUP
EOF

	( cd "${ARCHISO_FOLDER}/"; sudo mkarchiso -v -w work/ -o out/ ./; )
fi

if [ ! -f "./test.qcow2" ];
then
	qemu-img create -f qcow2 ./test.qcow2 15G
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
