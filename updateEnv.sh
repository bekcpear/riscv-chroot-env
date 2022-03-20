#!/usr/bin/env bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/preprocess.sh"

echo "preparing environment ..."

[[ -x ${rootfs}${chroot_static_qemu_bin#/} ]] || cp ${static_qemu_bin} ${rootfs}${chroot_static_qemu_bin#/}

echo ">>> appending make.conf ..."
makeConf="${rootfs}etc/portage/make.conf"
sed -Ei '/^###TEST_CONF_START###$/,/^###TEST_CONF_END###$/d' ${makeConf}
sed -E 's/@NPROC@/'$(($(nproc) - 2))'/' ${myPath}/conf.d/make.conf >>${makeConf}

echo ">>> touching package.{use,unmask}/zzz ..."
mkdir -p ${rootfs}etc/portage/package.{use,unmask}
touch ${rootfs}etc/portage/package.{use,unmask}/zzz

echo ">>> copying other configuration files ..."
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

# patch portage to make the build dir accessible for normal users
# this is convenient for a test environment
echo ">>> patching permissions for portage runtime directories ..."
sed -i 's/0o660/0o644/' ${rootfs}usr/lib/python*/site-packages/portage/util/_async/PipeLogger.py
sed -i 's/0o700/0o755/;s/0o2770/0o2775/' ${rootfs}usr/lib/python*/site-packages/portage/package/ebuild/prepare_build_dirs.py

echo "done."
