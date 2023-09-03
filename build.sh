#!/bin/bash

ARCH=x86_64

export LC_ALL=POSIX

set +h -e
umask 022

if [ ! -d build ]; then mkdir build; fi
cd build

if [ ! -d root ]; then mkdir root; fi

cd root

if [ ! -d lib ]; then mkdir lib; fi

if [ ! -d gnu ]; then tar vfx $(guix pack -L ../.. --system=$ARCH-linux -S /bin=bin -S /sbin=sbin bash coreutils util-linux cryptsetup ncurses grep diffutils torsocks curl net-tools sed dhcpcd module-init-tools findutils); fi
cd ..

cp ../config/init root/
cp ../config/magic.bin root/
chmod 755 root/init

cd root
find . -print0 | cpio --null --create --verbose --format=newc | xz --best --check=crc32 > ../initramfs.cpio.xz

cd ../..
cp build/initramfs.cpio.xz .
