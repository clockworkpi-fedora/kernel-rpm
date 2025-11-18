#!/bin/sh
set -e

# Configuration
GIT_SOURCE_URL="https://github.com/clockworkpi-fedora/kernel-rpm"
GIT_SOURCE_DIR="clockworkpi-fedora-kernel-rpm"
UPSTREAM_COPR="kwizart/kernel-longterm-6.12"
BUILD_ID="09758162"
KERNEL_VERSION="6.12.57"
KERNEL_RELEASE="200"
SRPM_FILE_NAME="kernel-longterm.src.rpm"
SRC_DIR="src"
BUILD_DIR="build"

rm -rf $GIT_SOURCE_DIR || true
rm -r $SRC_DIR || true
rm -r $BUILD_DIR || true
mkdir $SRC_DIR
mkdir $BUILD_DIR

echo "Downloading base kernel-longterm src.rpm..."
BASE_SRPM_URL="https://download.copr.fedorainfracloud.org/results/$UPSTREAM_COPR/fedora-43-aarch64/$BUILD_ID-kernel-longterm/kernel-longterm-$KERNEL_VERSION-$KERNEL_RELEASE.fc43.src.rpm"
wget -q "$BASE_SRPM_URL" -O $SRPM_FILE_NAME

echo "Extracting src rpm..."
rpmdev-extract -C $BUILD_DIR $SRPM_FILE_NAME 
pushd $BUILD_DIR
EXTRACT_FILENAME=$(ls)
mv $EXTRACT_FILENAME/* .
rmdir $EXTRACT_FILENAME
popd

echo "Cloning patch repo..."
git clone $GIT_SOURCE_URL $GIT_SOURCE_DIR

pushd $GIT_SOURCE_DIR
echo "Computing repo diff..."
INITIAL_COMMIT=$(git rev-list --max-parents=0 HEAD)
git diff $INITIAL_COMMIT HEAD -p --relative=src src > patch
popd

cp $GIT_SOURCE_DIR/patch $BUILD_DIR/patch

pushd $BUILD_DIR
echo "Applying repo diff as a patch to src rpm..."
patch -p1 < patch
rm patch
popd

echo "Done!"
