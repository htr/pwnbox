#!/usr/bin/env bash

perr() {
  echo "$@" 1>&2
}

usage() {
  perr "usage: $0 -o output-image.qcow2 -s image_size"
  perr ""
  perr "  the generated image format is qcow2"
  perr "  the image_size unit is GiB"
  exit 1
}

while getopts "o:s:" opt; do
  case "${opt}" in
    o)
      output_image=${OPTARG}
      ;;
    s)
      image_size=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done


if [[ -z "$output_image" ]] || [[ -z "$image_size" ]] ; then
  usage
fi

if [[ -f "$output_image" ]] ; then
  perr "$output_image already exists"
  exit 1
fi

perr "downloading linux and initrd.gz"
wget -nc http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux
wget -nc http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz

perr "creating disk image"
qemu-img create -f qcow2 $output_image "${image_size}G"

perr "starting qemu"

qemu-system-x86_64 -machine q35,accel=kvm,vmport=off -m 1G -smp 4 \
  -object iothread,id=io1 -device virtio-blk-pci,drive=disk0,iothread=io1 \
  -drive if=none,id=disk0,cache=unsafe,format=qcow2,aio=threads,file=$output_image \
  -device virtio-net-pci,netdev=net0 \
  -netdev 'user,id=net0,guestfwd=tcp:10.0.2.55:80-cmd:busybox httpd -i -h ./artifacts' \
  -kernel ./linux -initrd initrd.gz \
  -append 'console=ttyS0 install DEBIAN_FRONTEND=text auto=true preseed/url=http://10.0.2.55:80/preseed.cfg net.ifnames=0 locale=en_US keymap=us hostname=myvm domain=""' -nographic -no-reboot


