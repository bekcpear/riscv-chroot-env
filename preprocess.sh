#!/usr/bin/env bash
#

set -e

if [[ -n ${_PREPROCESSED} ]]; then
  return
fi
export _PREPROCESSED=1

if [[ ${EUID} -ne 0 ]]; then
  echo "should be root user for now!"
  exit 1
fi

if [[ ! ${1} =~ ^- ]]; then
  instance="${1}"
  shift || true
fi

myPath=$(dirname $(realpath $0))
. "${myPath}/env"

dirs=(
  rootfs_path_prefix # should be at the first place
  stage3_dir
  )

files=(
  static_qemu_bin
  )

for f in ${dirs[@]} ${files[@]}; do
  if [[ ! ${!f} =~ ^/ ]]; then
    eval "${f}=${myPath}/${!f}"
  fi
done

if [[ -n ${instance} ]]; then
  rootfs=${rootfs_path_prefix%%/}_${instance}
else
  rootfs=${rootfs_path_prefix%%/}_${default_instance}
fi

unset dirs[0]
dirs+=(rootfs)
# for secure, append a / to dir
for f in ${dirs[@]}; do
  eval "${f}=\${${f}%%/}/"
done

# export variables
for f in ${dirs[@]} ${files[@]}; do
  eval "export ${f}"
done
