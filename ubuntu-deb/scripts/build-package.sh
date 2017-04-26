#!/bin/bash

# This script runs inside the container
cd "${0%/*}"
shopt -s extglob

for CN24_CONFIG in $CN24_CONFIGS; do
  echo "Making target directory"
  mkdir cn24-$CN24_CONFIG-$CN24_VERSION
  cd cn24-$CN24_CONFIG-$CN24_VERSION

  # Copy files from repo
  echo "Copying files..."
  cp -r ../cn24-src/!(distribution|cmake-build-*) ./

  # Make origin tarball appear
  echo "Building package..."
  echo "Downloading origin tarball..."
  wget https://launchpad.net/~cn24-team/+archive/ubuntu/ppa/+files/cn24-${CN24_CONFIG}_$CN24_VERSION.orig.tar.gz -P ..
  if [ ! -e ../cn24-${CN24_CONFIG}_$CN24_VERSION.orig.tar.gz ]; then
    echo "Could not find original tarball on launchpad, rebuilding..."
    touch ../cn24-${CN24_CONFIG}_$CN24_VERSION-orig-missing
    tar -cz -f ../cn24-${CN24_CONFIG}_$CN24_VERSION.orig.tar.gz *
  fi

  echo "Moving debian control files..."
  cp -r ../debian debian

  DISTRO_CODE=$(lsb_release -c -s)
  echo "Adding changelog info... ($DISTRO_CODE)"
  echo "cn24-$CN24_CONFIG ($CN24_VERSION-$PACKAGE_VERSION~$DISTRO_CODE) $DISTRO_CODE; urgency=low" > debian/changelog
  echo "" >> debian/changelog
  echo "  * See CN24 wiki for detailed changelog" >> debian/changelog
  echo "" >> debian/changelog
  echo " -- Clemens-Alexander Brust <clemens-alexander.brust@uni-jena.de>  $(date -R)" >> debian/changelog
  
  echo "Moving appropriate files"
  cp debian/rules.$CN24_CONFIG debian/rules
  cp debian/control.$CN24_CONFIG debian/control
  cp debian/cn24.install debian/cn24-${CN24_CONFIG}.install
  cp debian/cn24-dev.install debian/cn24-${CN24_CONFIG}-dev.install
  cp debian/cn24.install debian/cn24-${CN24_CONFIG}.dirs
  cp debian/cn24-dev.install debian/cn24-${CN24_CONFIG}-dev.dirs

  # Create "origin" tarball

  echo "Building package..."
  if [ -e ../cn24-${CN24_CONFIG}_$CN24_VERSION-orig-missing ]; then
    debuild -us -uc -j12
  else
    debuild -sd -us -uc -j12
  fi

  cd ..
  ls *.deb
done

echo "Signing packages..."
for CN24_CONFIG in $CN24_CONFIGS; do
  cd cn24-$CN24_CONFIG-$CN24_VERSION
  if [ -e ../cn24-${CN24_CONFIG}_$CN24_VERSION-orig-missing ]; then
    debuild -S
  else
    debuild -sd -S
  fi
  cd ..
done

cp *.deb dist-tmp/
cp *.changes dist-tmp/
cp *.tar.gz dist-tmp/
echo "To upload your package to the ppa, run the following commands:"
for CN24_CONFIG in $CN24_CONFIGS; do
  echo "dput ppa:cn24-team/ppa cn24-${CN24_CONFIG}_$CN24_VERSION_*_source.changes"
done

echo 'Otherwise, you can just type "exit" at the command prompt.'

bash
