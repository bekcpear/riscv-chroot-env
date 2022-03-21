#!/usr/bin/env bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/preprocess.sh"

if [[ ! -d ${rootfs} ]]; then
  rootfs=${rootfs%%/}
  rootfs=${rootfs%/*}/${default_instance%%/}/
fi

[[ -d ${rootfs}etc/portage && -w ${rootfs}etc/portage ]] ||
  { echo "${rootfs}etc/portage/ is unwritable"; exit 1; }

set -- "${@}" d3aef8235d8c

while :; do
  case ${1} in
    -a)
      shift
      dest="${1}"
      shift
      ;;
    -d)
      shift
      delete_patch=1
      ;;
     -*)
      shift
      shift
      ;;
    d3aef8235d8c)
      break
      ;;
    *)
      patches+="${1} "
      shift
      ;;
  esac
done

if [[ -z ${dest} ]]; then
  echo "please use '-a' to specify the destination."
  exit 1
fi

realinstance=${rootfs%%/}
realinstance=${realinstance##*/}
if [[ ${realinstance} != ${instance} ]]; then
  patches+="${instance}"
fi

if [[ -z ${delete_patch} ]]; then
  mkdir -p ${rootfs}etc/portage/patches/${dest##/}
  set -- "cp ${patches} ${rootfs}etc/portage/patches/${dest##/}"
else
  echo ">>> pushd ${rootfs}etc/portage/patches/${dest##/}"
  pushd ${rootfs}etc/portage/patches/${dest##/} >/dev/null
  set -- rm -f ${patches}
fi
echo ">>> ${@}"
eval "${@}"
