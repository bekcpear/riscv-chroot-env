#!/usr/bin/env bash
#

set -e

. "$(dirname $(realpath $0))/preprocess.sh"

[[ -w ${rootfs} ]] || { echo "'${rootfs}' does not exists or non-writable"; exit 1; }

findmnt ${rootfs}tmp/ >/dev/null || mount --types tmpfs tmpfs ${rootfs}tmp/
findmnt ${rootfs}var/tmp/ >/dev/null || mount --types tmpfs tmpfs ${rootfs}var/tmp/
setfacl -d -m o::rwx ${rootfs}{var/,}tmp

#--tmpfs /tmp \
#--tmpfs /var/tmp \
ionice -c 3 \
nice -n 19 \
bwrap \
--bind ${rootfs} / \
--bind /var/cache/distfiles /var/cache/distfiles \
--ro-bind /etc/resolv.conf /etc/resolv.conf \
--ro-bind /var/db/repos/gentoo /var/db/repos/gentoo \
--dev /dev \
--proc /proc \
--tmpfs /run \
--perms 1777 --tmpfs /dev/shm \
--unshare-uts --hostname rv-qemuu-${rootfs##*/rootfs_} \
"${@}" \
/bin/bash --login

#--unshare-all --uid 0 --gid 0 \
