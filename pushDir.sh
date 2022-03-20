#!/usr/bin/env bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/preprocess.sh"

if [[ $# -gt 0 ]]; then
  if [[ ${1} == '-c' ]]; then
    dir_pattern_seed="${2}"
  fi
fi

[[ -d ${rootfs} && -x ${rootfs} ]] \
  || { echo "directory ${rootfs} does not exists or is unexecutable"; exit 1; }

eval "$(grep '^[[:space:]]*PORTAGE_TMPDIR=' \
  ${rootfs}usr/share/portage/config/make.globals \
  ${rootfs}etc/portage/make.conf | tail -1 | cut -d':' -f2)"

dirs=$(LC_ALL=C find ${rootfs}${PORTAGE_TMPDIR##/} -maxdepth 4 -type d)

dir_pattern=
while read -r p; do
  dir_pattern+="\/[^\/]*${p}[^\/]*"
done <<<"${dir_pattern_seed//\//$'\n'}"

declare -a select_dirs
while read -r p; do
  if [[ -z ${dir_len} ]]; then
    dir_len=${#p}
  fi
  if [[ ${#p} -gt ${dir_len} ]]; then
    continue
  fi
  select_dirs+=("${p}")
done <<<$(eval "<<<'${dirs}' sed -nE '/${dir_pattern}/p'")

if [[ ${#select_dirs[@]} -gt 1 ]]; then
  echo -e "\e[36mselect one from:\e[0m"
  for (( i = 0; i < ${#select_dirs[@]}; i++ )); do
    echo "  [${i}] ${select_dirs[i]}"
  done
  read -p "select: " theindex
  select_dirs[0]="${select_dirs[${theindex}]}"
elif [[ ${#select_dirs[@]} -lt 1 || ${select_dirs[0]} == "" ]]; then
  echo "no matched path!"
  exit 0
fi

if [[ -d ${select_dirs[0]} ]]; then
  pushingdir=${select_dirs[0]}
else
  pushingdir=${rootfs}
fi

echo ">>> shell into ${pushingdir} ..."
echo "[press CTRL-D to exit]"
pushd ${pushingdir} >/dev/null
unset _PREPROCESSED
eval "exec ${SHELL} -i"
