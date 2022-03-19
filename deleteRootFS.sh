#!/usr/bin/env bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/preprocess.sh"

if [[ ! -d ${rootfs} ]]; then
  echo "${rootfs} is not a directory or does not exists!"
  exit 1
else
  _PARENT=$(dirname ${rootfs})
  mkdir -p ${_PARENT}
  if btrfs inspect-internal rootid ${_PARENT} &>/dev/null; then
    set -- btrfs subvolume delete ${rootfs}
  else
    set -- rm -rf ${rootfs}
  fi

  echo ">>> ${myPath}/clearMount.sh"
  echo ">>> ${@}"
  # wait for secure
  WAIT=5
  echo -en "Starting in: \e[33m\e[1m"
  while [[ ${WAIT} -gt 0 ]]; do
    echo -en "${WAIT} "
    WAIT=$((${WAIT} -  1))
    sleep 1
  done
  echo -e "\e[0m"

  ${myPath}/clearMount.sh

  "${@}"
fi

