#!/usr/bin/env bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/preprocess.sh"

if [[ -e ${rootfs} ]]; then
  echo "${rootfs} exists!"
  exit 0
fi

# set an source rootfs for copying
if [[ $# -gt 0 ]]; then
  if [[ ${1} == "-s" ]]; then
    shift
  else
    echo "unrecognized option: ${@}"
    exit 1
  fi
  if [[ ${1} =~ / ]]; then
    sinstance=${1}
  else
    sinstance=${rootfs%%/}
    sinstance=${sinstance%/*}/${1}
  fi
  if [[ ! -d ${sinstance} ]]; then
    echo "invalid source instance (${sinstance}) for copying."
    exit 1
  fi
fi

_PARENT=$(dirname ${rootfs})
mkdir -p ${_PARENT}
if btrfs inspect-internal rootid ${_PARENT} &>/dev/null; then
  set -- btrfs subvolume create ${rootfs} "&&" chattr +C ${rootfs}
  if [[ -n ${sinstance} ]]; then
    set -- btrfs subvolume snapshot ${sinstance} ${rootfs} "&&" chattr +C ${rootfs}
  fi
else
  set -- mkdir -p ${rootfs}
  if [[ -n ${sinstance} ]]; then
    set -- cp -a ${sinstance} ${rootfs}
  fi
fi

echo "${@}"
eval "${@}"

if [[ -n ${sinstance} ]]; then
  echo "skip updating portage environment"
  exit 0
fi

stage3=$(LC_ALL=C find ${stage3_dir} -name 'stage3-*.tar.xz' | tail -1)

set -- tar xpf ${stage3} -C ${rootfs} --xattrs --xattrs-include='*.*' --exclude='./dev/*'
echo "${@}"
"${@}"

${myPath}/updateEnv.sh

# make others can modify /etc/portage dir
find ${rootfs}etc/portage -type d -exec setfacl -m o::rwx '{}' \;
find ${rootfs}etc/portage -type f -exec setfacl -m o::rw '{}' \;
setfacl -R -d -m o::rwx ${rootfs}etc/portage

