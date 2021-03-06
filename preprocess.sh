#!/usr/bin/env bash
#

set -e

if [[ -n ${myArrays} ]]; then
  eval "${myArrays}"
fi

if [[ -n ${_PREPROCESSED} ]]; then
  return
fi
export _PREPROCESSED=1

if [[ ${EUID} -ne 0 ]]; then
  continue=0
  case $(realpath ${0}) in
    *pushDir.sh|*getLatest.sh|*doPatch.sh)
      continue=1
      ;;
  esac
  if [[ ${continue} == 0 ]]; then
    echo "should be root user for now!"
    exit 1
  fi
fi

set +e
unset GETOPT_COMPATIBLE
getopt -T
if [[ ${?} != 4 ]]; then
  echo "The command 'getopt' of Linux version is necessory to parse parameters."
  exit 1
fi
args=$(getopt -o 'fs:c:a:dl' -n ${0} -- "$@")
if [[ ${?} != 0 ]]; then
  exit 1
fi
set -e
eval "set -- ${args}"

args=
for arg; do
  if [[ ${arg} != "--" ]]; then
    args+="${arg} "
  else
    shift
    break
  fi
  shift
done

if [[ -n ${1} ]]; then
  instance="${1}"
  shift
fi

args+="$*"
eval "set -- ${args}"

myPath=$(dirname $(realpath $0))
. "${myPath}/env"

dirs=(
  rootfs_path_prefix
  stage3_dir
  )

files=(
  static_qemu_bin
  )

chroot_files=(
  chroot_static_qemu_bin
  )

vars=(
  default_instance
  force_update
  mirror_url
  )

arrays=(
  ignore_patterns
  )


# update to absolute path for files/dirs in the host environment
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

dirs+=(rootfs)
# for secure, append a / to dir
for f in ${dirs[@]}; do
  eval "${f}=\${${f}%%/}/"
done

# export variables
for f in ${dirs[@]} ${files[@]} ${chroot_files[@]} ${vars[@]}; do
  eval "export ${f}"
done

# export arrays, but with declare format
# bug: https://www.mail-archive.com/bug-bash@gnu.org/msg01774.html
# see also: https://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script
for a in ${arrays[@]}; do
  eval "myArrays+=\$'\n'\"\$(declare -p ${a})\""
done
export myArrays
