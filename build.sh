#!/bin/sh
set -e
docker build -f Dockerfile.build -t amazon-q-builder .
docker run --rm \
    -v "$PWD:/src" \
    -v amazon-q-cargo:/root/.cargo/registry \
    -e HOST_UID=$(id -u) -e HOST_GID=$(id -g) \
    --cap-add SYS_ADMIN --device /dev/fuse \
    amazon-q-builder --skip-tests --skip-lints --variant full "$@"
