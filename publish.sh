#!/bin/bash

set -eux

SCRIPT=$(realpath $0)
SCRIPT_PATH=$(dirname $SCRIPT)
PRECOGNIZE_SOURCE_PATH=${PRECOGNIZE_SOURCE_PATH:-${SCRIPT_PATH}}
PRECOGNIZE_PYPI_DOMAIN_NAME=${PRECOGNIZE_PYPI_DOMAIN_NAME:-pypi.precog.local}
PRECOGNIZE_PYPI_IP=${PRECOGNIZE_PYPI_IP:-127.0.0.1}

PRECOGNIZE_UID_GID=$(id -u):$(id -g)

PRECOGNIZE_PYTHON_PUBLISH_IMAGE=${PRECOGNIZE_PYTHON_PUBLISH_IMAGE:-precognize/python-publish:latest}

if [[ "${PRECOGNIZE_PYTHON_PUBLISH_IMAGE}" == "docker.precog.local"* ]]; then
  docker pull ${PRECOGNIZE_PYTHON_PUBLISH_IMAGE}
fi

docker run \
  --add-host ${PRECOGNIZE_PYPI_DOMAIN_NAME}:${PRECOGNIZE_PYPI_IP} \
  -u "${PRECOGNIZE_UID_GID}" \
  -v "${PRECOGNIZE_SOURCE_PATH}":/source \
  -w /source \
  --network=host \
  ${PRECOGNIZE_PYTHON_PUBLISH_IMAGE} \
  publish.sh /source/dist/*.whl
