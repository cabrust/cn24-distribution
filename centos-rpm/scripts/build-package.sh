#!/bin/bash

# This script runs inside the container
cd "${0%/*}"
shopt -s extglob

# Setup build tree
rpmdev-setuptree
mkdir /root/rpmbuild/tmp

cp rpm/.rpmmacros /root/

for CN24_CONFIG in $CN24_CONFIGS; do
  echo "Making target directory for $CN24_CONFIG"
  mkdir cn24-$CN24_CONFIG-$CN24_RPM_VERSION
  cd cn24-$CN24_CONFIG-$CN24_RPM_VERSION

  echo "Copying files..."
  cp -r ../cn24-src/!(*distribution|cmake-build-*|build*) ./

  echo "Making source tarball..."
  cd ..
  tar -cz -f /root/rpmbuild/SOURCES/cn24-${CN24_CONFIG}_$CN24_RPM_VERSION.orig.tar.gz cn24-$CN24_CONFIG-$CN24_RPM_VERSION/*
done

for CN24_CONFIG in $CN24_CONFIGS; do
  echo "Making spec file for $CN24_CONFIG"
  echo "Version: ${CN24_RPM_VERSION}" > /root/rpmbuild/SPECS/cn24-${CN24_CONFIG}.spec
  echo "Release: ${CN24_RPM_RELEASE}%{?dist}" >> /root/rpmbuild/SPECS/cn24-${CN24_CONFIG}.spec
  echo 'BuildRoot: %{_tmppath}/%{name}-buildroot' >> /root/rpmbuild/SPECS/cn24-${CN24_CONFIG}.spec
  echo "Source0: cn24-${CN24_CONFIG}_$CN24_RPM_VERSION.orig.tar.gz" >> /root/rpmbuild/SPECS/cn24-${CN24_CONFIG}.spec
  cat rpm/cn24-${CN24_CONFIG}.spec >> /root/rpmbuild/SPECS/cn24-${CN24_CONFIG}.spec

  echo "Making RPM"
  rpmbuild -v -bb /root/rpmbuild/SPECS/cn24-${CN24_CONFIG}.spec
done

cp /root/rpmbuild/RPMS/x86_64/* dist-tmp/
bash

exit
