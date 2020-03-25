#!/bin/bash

set -o errexit

function realpath() {
  CURRENT_DIR=$(pwd)
  DIR=$(dirname "${1}")
  FILE=$(basename "${1}")
  cd "${DIR}"
  echo $(pwd)/"${FILE}"
  cd "${CURRENT_DIR}"
}

# check input parameters
if [[ "$#" -lt 2 ]]; then
  echo -e "Missing parameters.\nSee run_ags.sh . . --help"
  exit
fi

# handle input fna file
INPUT_FNA=$(basename "${1}")
INPUT_DIR=$(dirname $(realpath "${1}"))
shift

# handle input orfs file
if [[ -f "${1}" ]]; then
  INPUT_ORFS=$(basename "${1}")
  shift
fi

OUTPUT_DIR=$(dirname $(realpath "${1}"))
OUTPUT=$(basename "${1}")
shift

# Links within the container
CONTAINER_SRC_DIR=/input
CONTAINER_DST_DIR=/output

if [[ -n "${INPUT_ORFS}" ]]; then
  docker run \
    --volume "${INPUT_DIR}":"${CONTAINER_SRC_DIR}":rw \
    --volume "${OUTPUT_DIR}":"${CONTAINER_DST_DIR}":rw \
    --detach=false \
    --rm \
    --user $(id -u):$(id -g) \
     epereira/ags:latest \
    --input_fna "${CONTAINER_SRC_DIR}/${INPUT_FNA}" \
    --input_orfs "${CONTAINER_SRC_DIR}/${INPUT_ORFS}" \
    --outdir "${OUTPUT}" \
    $@
else
docker run \
    --volume "${INPUT_DIR}":"${CONTAINER_SRC_DIR}":rw \
    --volume "${OUTPUT_DIR}":"${CONTAINER_DST_DIR}":rw \
    --detach=false \
    --rm \
    --user $(id -u):$(id -g) \
     epereira/ags:latest  \
    --input_fna "${CONTAINER_SRC_DIR}/${INPUT_FNA}" \
    --outdir "${OUTPUT}" \
    $@
fi
