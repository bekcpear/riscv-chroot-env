#!/bin/bash
#

set -e

if [[ ${EUID} -ne 0 ]]; then
  echo "should be root user for now!"
  exit 1
fi

. "$(dirname $(realpath $0))/preprocess.sh"

findmnt ${rootfs}tmp/ >/dev/null || mount --types tmpfs tmpfs ${rootfs}tmp/
findmnt ${rootfs}var/tmp/ >/dev/null || mount --types tmpfs tmpfs ${rootfs}var/tmp/
setfacl -d -m o::rwx ${rootfs}{var/,}tmp

#--tmpfs /tmp \
#--tmpfs /var/tmp \
bwrap \
--bind ${rootfs} / \
--bind /var/cache/distfiles /var/cache/distfiles \
--ro-bind /etc/resolv.conf /etc/resolv.conf \
--ro-bind /var/db/repos/gentoo /var/db/repos/gentoo \
--dev /dev \
--proc /proc \
--tmpfs /run \
--perms 1777 --tmpfs /dev/shm \
--unshare-uts --hostname riscv-qemu-user \
"${@}" \
/bin/bash --login

#--unshare-all --uid 0 --gid 0 \
