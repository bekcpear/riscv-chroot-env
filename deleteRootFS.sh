#!/bin/bash
#

set -e

. "./env"

if [[ -e ${rootfs} ]]; then
  set -- btrfs subvolume delete ${rootfs}
  echo "${@}"
  "${@}"
fi

