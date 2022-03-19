#!/bin/bash
#

set -e

. "./env"

if [[ -e ${rootfs} ]]; then
  echo "exists"
  exit 0
fi

btrfs subvolume create ${rootfs}

set -- tar xpf ${stage3_dir}stage3-*.tar.xz -C ${rootfs} --xattrs-include='*.*' --numeric-owner
echo "${@}"
"${@}"
