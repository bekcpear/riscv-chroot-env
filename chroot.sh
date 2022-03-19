#!/usr/bin/env bash
#

set -e

. "$(dirname $(realpath $0))/preprocess.sh"

# do some checks
[[ -w ${rootfs} ]] || { echo "${rootfs} does not exists or is unwritable"; exit 1; }
[[ -x ${rootfs}${chroot_static_qemu_bin#/} ]] || \
  { echo "${rootfs}${chroot_static_qemu_bin#/} does not exists or is unexecutable"; exit 1; }
interpreters="$(grep 'interpreter' /proc/sys/fs/binfmt_misc/qemu-*)"
interpreter_matched=0
while read -r _ interpreter; do
  if [[ ${interpreter} == ${chroot_static_qemu_bin} ]]; then
    interpreter_matched=1
  fi
done <<<"${interpreters}"
[[ ${interpreter_matched} == 1 ]] || \
  { echo "qemu-user binary: ${chroot_static_qemu_bin}
is not matched with interpreters: ${interpreters}"; exit 1; }
[[ $(cat /proc/sys/fs/binfmt_misc/status) == "enabled" ]] || { echo "binfmt disabled"; exit 1; }


findmnt ${rootfs}tmp/ >/dev/null || mount --types tmpfs tmpfs ${rootfs}tmp/
findmnt ${rootfs}var/tmp/ >/dev/null || mount --types tmpfs tmpfs ${rootfs}var/tmp/
setfacl -d -m o::rwx ${rootfs}{var/,}tmp

hostname_suffix=${rootfs##*/rootfs/}
hostname_suffix=${hostname_suffix%%/}
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
--unshare-uts --hostname rv-qemuu-${hostname_suffix} \
"${@}" \
/bin/bash --login

#--unshare-all --uid 0 --gid 0 \
