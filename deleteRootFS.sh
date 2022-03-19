#!/bin/bash
#

set -e

. "./env"


if [[ -d ${rootfs} ]]; then
  ./clearMount.sh

  _PARENT=$(dirname ${rootfs})
  mkdir -p ${_PARENT}
  if btrfs inspect-internal rootid ${_PARENT} &>/dev/null; then
    set -- btrfs subvolume delete ${rootfs}
  else
    set -- rm -rf ${rootfs}
  fi

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

  "${@}"
fi

