#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  echo "USAGE: $0 <cn24 source folder> <cn24 version suffix> <package version> <centos version>"
  exit
fi

CN24_ROOT=$1
CN24_VERSION_SUFFIX=$2
if [ -e $CN24_ROOT/VERSION ]; then
  CN24_VERSION=$(cat $CN24_ROOT/VERSION)$CN24_VERSION_SUFFIX
  CN24_RPM_VERSION=$(cat $CN24_ROOT/RPM_VERSION)$CN24_VERSION_SUFFIX
else
  CN24_VERSION=$CN24_VERSION_SUFFIX
  CN24_RPM_VERSION=2
fi
PACKAGE_VERSION=$3
CN24_RPM_RELEASE=$PACKAGE_VERSION
CENTOS_VERSION=$4
if [ -z "$CN24_CONFIGS" ]; then
  CN24_CONFIGS="gpu cpu gpu-opencv"
fi

echo "Choosing CN24 install from $CN24_ROOT (Version $CN24_VERSION)"
echo "Using version $CENTOS_VERSION"

# Generate Dockerfile
echo "FROM centos:$CENTOS_VERSION" > Dockerfile.tmp.$CENTOS_VERSION
cat Dockerfile.general >> Dockerfile.tmp.$CENTOS_VERSION

# Execute this file on the host
docker build -f Dockerfile.tmp.$CENTOS_VERSION -t cn24pkg_centos:$CENTOS_VERSION .

TMP_BU=$(pwd)
cd $CN24_ROOT
CN24_SRC=$(pwd)
cd "$TMP_BU"
mkdir -p dist-tmp
rm -f dist-tmp/core

docker run -it --name cn24pkgbuilder -v $CN24_SRC:/cn24-pkg-out/cn24-src -v $(pwd)/rpm:/cn24-pkg-out/rpm -v $(pwd)/dist-tmp:/cn24-pkg-out/dist-tmp -v ~/.gnupg:/root/.gnupg -e "CN24_VERSION=$CN24_VERSION" -e "PACKAGE_VERSION=$PACKAGE_VERSION" -e "CN24_CONFIGS=$CN24_CONFIGS" -e "CN24_RPM_VERSION=$CN24_RPM_VERSION" -e "CN24_RPM_RELEASE=$CN24_RPM_RELEASE" cn24pkg_centos:$CENTOS_VERSION scl enable devtoolset-4 'bash /cn24-pkg-out/build-package.sh'
docker rm cn24pkgbuilder
