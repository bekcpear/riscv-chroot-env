#!/bin/bash
#

set -e

. "./env"

cp /usr/bin/qemu-riscv64 ${rootfs}usr/bin/

findmnt ${rootfs}tmp/ >/dev/null || mount --types tmpfs tmpfs ${rootfs}tmp/
findmnt ${rootfs}var/tmp/ >/dev/null || mount --types tmpfs tmpfs ${rootfs}var/tmp/

bwrap \
--bind ${rootfs} / \
--bind /var/cache/distfiles /var/cache/distfiles \
--ro-bind /etc/resolv.conf /etc/resolv.conf \
--ro-bind /var/db/repos/gentoo /var/db/repos/gentoo \
--dev /dev \
--proc /proc \
--tmpfs /run \
--perms 1777 --tmpfs /dev/shm \
/bin/bash --login
