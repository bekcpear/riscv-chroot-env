#!/bin/bash
#

set -e

. "./env"

if [[ -e ${rootfs} ]]; then
  echo "exists"
  exit 0
fi

_PARENT=$(dirname ${rootfs})
mkdir -p ${_PARENT}
if btrfs inspect-internal rootid ${_PARENT} &>/dev/null; then
  btrfs subvolume create ${rootfs}
  chattr +C ${rootfs}
else
  mkdir -p ${rootfs}
fi

set -- tar xpf ${stage3_dir}stage3-*.tar.xz -C ${rootfs} --xattrs-include='*.*' --numeric-owner
echo "${@}"
"${@}"
