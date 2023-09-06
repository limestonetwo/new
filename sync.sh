#!/bin/bash

#copy ccache
cd ~/
rm -rf ~/ccache
mkdir -p ~/ccache
rclone copy 298:RRQN/ccache.tar.gz ~/ -P
time tar xf ccache.tar.gz
cd ~/

## Sync
mkdir -p ~/rom
cd ~/rom
rm -rf * .repo
repo init -q --no-repo-verify --depth=1 -u https://github.com/ResurrectionRemix/platform_manifest -b Q -g default,-mips,-darwin,-notdefault
git clone https://github.com/limestonetwo/local_manifest --depth 1 -b main .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)

### BUILD
cd ~/rom
sudo ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
. build/envsetup.sh
export CCACHE_DIR=~/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 50G -F 0
export BUILD_USERNAME="darknius"
export BUILD_HOSTNAME="darx-labs"
lunch rr_finix-userdebug
export ALLOW_MISSING_DEPENDENCIES=true
export BUILD_BROKEN_USES_BUILD_COPY_HEADERS=true
export BUILD_BROKEN_DUP_RULES=true
export GAPPS=true
m bacon -j$(nproc --all)

##upload
rclone copy ~/rom/out/target/product/citrus/RR-*.zip 298:citrus -P