#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  echo "USAGE: $0 <cn24 source folder> <cn24 version> <package version> <ubuntu version>"
  exit
fi

CN24_ROOT=$1
CN24_VERSION=$2
PACKAGE_VERSION=$3
UBUNTU_VERSION=$4
echo "Choosing CN24 install from $CN24_ROOT (Version $CN24_VERSION)"
echo "Using Ubuntu $UBUNTU_VERSION"

# Generate Dockerfile
echo "FROM ubuntu:$UBUNTU_VERSION" > Dockerfile.tmp.$UBUNTU_VERSION
cat Dockerfile.general >> Dockerfile.tmp.$UBUNTU_VERSION

# Execute this file on the host
docker build -f Dockerfile.tmp.$UBUNTU_VERSION -t cn24pkg:$UBUNTU_VERSION .

TMP_BU=$(pwd)
cd $CN24_ROOT
CN24_SRC=$(pwd)
cd "$TMP_BU"

docker run -it --name cn24pkgbuilder -v $CN24_SRC:/cn24-pkg-out/cn24-src -v $(pwd)/debian:/cn24-pkg-out/debian -e "CN24_VERSION=$CN24_VERSION" -e "PACKAGE_VERSION=$PACKAGE_VERSION" cn24pkg:$UBUNTU_VERSION bash /cn24-pkg-out/build-package.sh
docker rm cn24pkgbuilder
