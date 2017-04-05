#!/bin/bash

# This script runs inside the container
cd "${0%/*}"

echo "Making target directory"
mkdir cn24-$CN24_VERSION
cd cn24-$CN24_VERSION

# Copy files from repo
echo "Copying files..."
shopt -s extglob
cp -r ../cn24-src/!(distribution) ./

echo "Moving debian control files..."
cp -r ../debian debian

DISTRO_CODE=$(lsb_release -c -s)
echo "Adding changelog info... ($DISTRO_CODE)"
echo "cn24 ($CN24_VERSION-$PACKAGE_VERSION~$DISTRO_CODE) $DISTRO_CODE; urgency=low" > debian/changelog
echo "" >> debian/changelog
echo "  * Change" >> debian/changelog
echo "" >> debian/changelog
echo " -- Clemens-Alexander Brust <clemens-alexander.brust@uni-jena.de> $(date -R)" >> debian/changelog

# Create "origin" tarball
echo "Creating origin tarball..."
tar -cz -f ../cn24_$CN24_VERSION.orig.tar.gz *

echo "Building package..."
debuild -us -uc -j12
bash
