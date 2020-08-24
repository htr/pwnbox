#!/usr/bin/env bash

perr() {
  echo "$@" 1>&2
}

usage() {
  perr "usage: $0 -i image.qcow2"
  perr ""
  perr "  the image format is assumed to be qcow2"
  exit 1
}

while getopts "i:" opt; do
  case "${opt}" in
    i)
      image=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done


if [[ -z "$image" ]] ; then
  usage
fi

perr "starting qemu"

qemu-system-x86_64 -machine q35,accel=kvm,vmport=off -m 1G -smp 4 \
  -object iothread,id=io1 -device virtio-blk-pci,drive=disk0,iothread=io1 \
  -drive if=none,id=disk0,cache=unsafe,format=qcow2,aio=threads,file=$image \
  -device virtio-net-pci,netdev=net0 \
  -netdev 'user,id=net0,hostfwd=tcp::50022-:22' \
  -curses -nographic -no-reboot

