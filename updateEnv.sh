#!/usr/bin/env bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/preprocess.sh"

echo "preparing environment ..."

[[ -x ${rootfs}${static_qemu_bin#/} ]] || cp ${static_qemu_bin} ${rootfs}${static_qemu_bin#/}

makeConf="${rootfs}etc/portage/make.conf"
sed -Ei '/^###TEST_CONF_START###$/,/^###TEST_CONF_END###$/d' ${makeConf}
sed -E 's/@NPROC@/'$(($(nproc) - 2))'/' ${myPath}/conf.d/make.conf >>${makeConf}

mkdir -p ${rootfs}etc/portage/package.{use,unmask}
touch ${rootfs}etc/portage/package.{use,unmask}/zzz

while read -r testconf; do
  file=${rootfs}etc/portage/${testconf#${myPath}/conf.d/}
  ex=0
  if [[ ! -e ${file} ]]; then
    ex=1
  elif [[ ${force_update} == 1 ]]; then
    ex=1
    echo "force update to ${file}"
  else
    echo "skip ${testconf}"
  fi
  if [[ ${ex} == 1 ]]; then
    mkdir -p $(dirname ${file})
    cp ${testconf} ${file}
  fi
done <<<"$(eval "find ${myPath}/conf.d \\( \
                  ! -name 'make.conf' \
                  $(for p in ${ignore_patterns[@]};do echo -n " -and ! -name '${p}'"; done) \
                  -and -type f \\)")"

echo "done."
