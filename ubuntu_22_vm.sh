#!/bin/sh

set -ue -o pipefail

VERSION=jammy
IMAGE=$VERSION-server-cloudimg-amd64.img
SIZE=30G

# https://documentation.ubuntu.com/public-images/public-images-how-to/use-local-cloud-init-ds/

sudo apt install -y cloud-image-utils qemu-system-x86

if [ ! -e $IMAGE ]; then
	wget http://cloud-images.ubuntu.com/$VERSION/current/$IMAGE
fi

if [ ! -e disk.img ]; then
	cp $IMAGE disk.img
	qemu-img resize disk.img $SIZE
fi

cat > user-data.yaml <<EOF
#cloud-config
password: test
chpasswd:
  expire: False
ssh_pwauth: True
#ssh_authorized_keys:
#  - ssh-rsa AAAA...UlIsqdaO+w==
bootcmd:
  - mkdir -p /home/ubuntu/hostdir
  - modprobe 9pnet_virtio || true
  - modprobe 9p || true

mounts:
  - [ "hostshare", "/home/ubuntu/hostdir", "9p",
      "trans=virtio,version=9p2000.L,msize=1048576,rw,_netdev,x-systemd.automount,noatime",
      "0", "0" ]
EOF

cloud-localds seed.img user-data.yaml
rm user-data.yaml

QEMU_ARGS=

add_usb_device() {
    local vendor="$1"
    local product="$2"

    for dev in /sys/bus/usb/devices/*; do
        dev_vendor=$(cat "$dev/idVendor" 2> /dev/null)
        dev_product=$(cat "$dev/idProduct" 2> /dev/null)

        if [ "$dev_vendor" = "$vendor" -a "$dev_product" = "$product" ]; then
            bus=$(cat "$dev/busnum")
            port=$(cat "$dev/devpath")
            for iface in "$dev":*; do
                if [ -d "$iface/driver" ]; then
                    echo "Ignoring $bus - $port (already used)"
                else
                    QEMU_ARGS="$QEMU_ARGS -device usb-host,hostbus=$bus,hostport=$port,guest-reset=true,guest-resets-all=true"
                    return 0
                fi
            done
        fi
    done

    return 1
}

if ! add_usb_device 325b 8100; then
    echo "Failed to find a Morse USB device to pass through."
    exit 1
fi

qemu-system-x86_64  \
  -cpu host -machine type=q35,accel=kvm -m 8192 -smp 8 -usb \
  $QEMU_ARGS \
  -nographic \
  -netdev id=net00,type=user,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net00 \
  -virtfs local,path="$(pwd)",mount_tag=hostshare,security_model=mapped-xattr,id=hostshare \
  -drive if=virtio,format=qcow2,file=disk.img \
  -drive if=virtio,format=raw,file=seed.img
