#!/usr/bin/env bash

# error handling mode.
set -e

# dependencies to build.
PACKAGES="argon2 enchant secp256k1"

# extensions to build.
EXTENSIONS="apcu imagick hashids libsodium memcached mongodb msgpack psr redis scalar_objects swoole xdebug"

# define root packages source path.
SOURCES_PATH=$(pwd)

# ensure starts on sources path.
# shellcheck disable=SC2164
cd "${SOURCES_PATH}"

# function for building packages.
function build_package()
{
    # alias package name from function input.
    PACKAGE_NAME=${1}
    # ensure previously built packages are available.
    sudo apk update
    # enter package source directory.
    # shellcheck disable=SC2164
    cd "$SOURCES_PATH/$PACKAGE_NAME"
    # give a little feedback about the current package being built.
    echo "----> Building Package: $PACKAGE_NAME"
    # checksum source files before build.
    # abuild checksum
    # build the package from source.
    abuild -r
    # return shell to previous location for safe scripting!
    # shellcheck disable=SC2164
    cd "${SOURCES_PATH}"
}

# build base packages.
for PACKAGE in ${PACKAGES}; do
    # call the build function.
    build_package "${PACKAGE}"
done

# when full flag is provided, build PHP itself first.
if [[ "$1" == "--full" ]] || [[ "$2" == "--full" ]]; then
    # call the build function.
    build_package "php8"
fi

# build extensions.
for EXTENSION in ${EXTENSIONS}; do
    # call the build function, prefixing with "php8-".
    build_package "php8-${EXTENSION}"
done

# ensure the final destination is the sources path.
# shellcheck disable=SC2164
cd "$SOURCES_PATH"
