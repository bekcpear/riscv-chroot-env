#!/usr/bin/env bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/preprocess.sh"

echo "preparing environment ..."

[[ -x ${rootfs}${static_qemu_bin#/} ]] || cp ${static_qemu_bin} ${rootfs}${static_qemu_bin#/}

makeConf="${rootfs}etc/portage/make.conf"
sed -Ei '/^###TEST_CONF_START###$/,/^###TEST_CONF_END###$/d' ${makeConf}
sed -E 's/@NPROC@/'$(($(nproc) - 2))'/' ${myPath}/conf/make.conf >>${makeConf}

mkdir -p ${rootfs}etc/portage/package.{use,unmask}
touch ${rootfs}etc/portage/package.{use,unmask}/zzz

echo "done."
