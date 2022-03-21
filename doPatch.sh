#!/usr/bin/env bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/preprocess.sh"

if [[ ! -d ${rootfs} ]]; then
  rootfs=${rootfs%%/}
  rootfs=${rootfs%${instance%%/}}
  rootfs=${rootfs%%/}/${default_instance%%/}/
fi

[[ -d ${rootfs}etc/portage && -w ${rootfs}etc/portage ]] ||
  { echo "${rootfs}etc/portage/ is unwritable"; exit 1; }

set -- "${@}" d3aef8235d8c

patch_action=copy
while :; do
  case ${1} in
    -a)
      shift
      dest="${1}"
      shift
      ;;
    -d)
      shift
      patch_action=delete
      ;;
    -l)
      shift
      patch_action=list
      ;;
     -*)
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
realinstance=${realinstance#${rootfs_path_prefix%%/}}
realinstance=${realinstance##/}
if [[ ${realinstance} != ${instance%%/} ]]; then
  patches+="${instance}"
fi

# do some checks
if [[ ${patches} =~ ^[[:space:]]*$ && ${patch_action} != "list" ]]; then
  echo "no patch specified!"
  exit 1
else
  if [[ ${patch_action} == "copy" ]]; then
    for patch in ${patches}; do
      if [[ ! -f ${patch} ]]; then
        invalid_patches+=$'\n'"  ${patch}"
      fi
    done
    if [[ -n ${invalid_patches} ]]; then
      echo "only regular file allowed!"
      echo "invalid: ${invalid_patches}"
      exit 1
    fi
  fi
fi

patches_dir="${rootfs}etc/portage/patches/${dest##/}"
case ${patch_action} in
  copy)
    mkdir -p ${patches_dir}
    set -- "cp ${patches} ${patches_dir}"
    ;;
  delete)
    echo ">>> pushd ${patches_dir}"
    pushd ${patches_dir} >/dev/null
    set -- rm -f ${patches}
    ;;
  list)
    set -- ls -1 ${patches_dir}
    ;;
esac

echo ">>> ${@}"
eval "${@}"
