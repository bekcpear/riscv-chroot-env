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

vars=(
  default_instance
  force_update
  ignore_patterns
  mirror_url
  )

for f in ${dirs[@]} ${files[@]}; do
  if [[ ! ${!f} =~ ^/ ]]; then
    eval "${f}=${myPath}/${!f}"
  fi
done

if [[ -n ${instance} ]]; then
  rootfs=${rootfs_path_prefix%%/}/${instance}
else
  rootfs=${rootfs_path_prefix%%/}/${default_instance}
fi

# warn the previous rootfs path has been replaced
_previous_rootfs=$(<<<${rootfs} sed -E 's/\/([^\/]+)\/?$/_\1/')
if [[ ! -d ${rootfs} && -d ${_previous_rootfs} ]]; then
  echo -e "\e[33mthe script has been updated to use a new rootfs path,
please run:\e[0m"
  echo -e "\e[36m  mv ${_previous_rootfs} ${rootfs}\e[0m"
  echo -e "\e[33mto update.\e[0m"
  exit 1
fi

unset dirs[0]
dirs+=(rootfs)
# for secure, append a / to dir
for f in ${dirs[@]}; do
  eval "${f}=\${${f}%%/}/"
done

# export variables
for f in ${dirs[@]} ${files[@]} ${vars[@]}; do
  eval "export ${f}"
done
