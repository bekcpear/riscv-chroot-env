#!/usr/bin/env bash
#

set -e

. "$(dirname $(realpath $0))/preprocess.sh"

DIR="${stage3_dir}"
URL="https://mirrors.bfsu.edu.cn/gentoo/releases/riscv/autobuilds/"
TYPE="rv64_lp64d-openrc"
INFO_TXT="${URL}latest-stage3-${TYPE}.txt"

wget -qO ${DIR}info ${INFO_TXT}

STAGE3_PATH=
while read path; do
  if [[ ! ${path} =~ ^# ]]; then
    STAGE3_PATH=${path% *}
  fi
done <${DIR}info

STAGE3_URL=${URL}${STAGE3_PATH}
STAGE3_DIGESTS=${URL}${STAGE3_PATH}.DIGESTS

CURRENT=$(LC_ALL=C ls -1 ${DIR}stage3-${TYPE}*.tar.xz 2>/dev/null | tail -1) || true
CURRENT=${CURRENT##*/}

if [[ ${CURRENT} == ${STAGE3_PATH##*/} ]]; then
  echo "Newest: ${STAGE3_PATH}"
  echo "Already updated."
  exit 0
fi

mkdir -p ${DIR}old
mv ${DIR}stage3-* ${DIR}old/ || true

wget -P ${DIR} ${STAGE3_URL}
wget -P ${DIR} ${STAGE3_DIGESTS}

pushd ${DIR}
sha512sum -c --ignore-missing *.DIGESTS
