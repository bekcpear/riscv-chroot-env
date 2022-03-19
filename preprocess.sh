#!/bin/bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/env"

dirs=(
  rootfs
  stage3_dir
  )

files=(
  static_qemu_bin
  )

for f in ${dirs[@]} ${files}; do
  if [[ ! ${!f} =~ ^/ ]]; then
    eval "${f}=${myPath}/${!f}"
  fi
done

# for secure, append a / to dir
for f in ${dirs[@]}; do
  eval "${f}=\${${f}%%/}/"
done
