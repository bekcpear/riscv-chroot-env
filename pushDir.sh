#!/usr/bin/env bash
#

set -e

myPath=$(dirname $(realpath $0))
. "${myPath}/preprocess.sh"

echo ">>> pushing ${rootfs} ..."
pushd ${rootfs} >/dev/null
eval "exec ${SHELL} -i"
