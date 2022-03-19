#!/bin/bash
#

. "./env"

findmnt ${rootfs}tmp/ >/dev/null && umount ${rootfs}tmp/
findmnt ${rootfs}var/tmp/ >/dev/null && umount ${rootfs}var/tmp/
