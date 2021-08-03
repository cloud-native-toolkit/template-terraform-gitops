#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

NAME="$1"
DEST_DIR="$2"

mkdir -p "${DEST_DIR}"

cp -R "${MODULE_DIR}/chart/${NAME}/"* "${DEST_DIR}"

if [[ -n "${VALUES_CONTENT}" ]]; then
  echo "${VALUES_CONTENT}" > "${DEST_DIR}/values.yaml"
fi

find "${DEST_DIR}" -name "*"
