#!/bin/sh

rm boot.img 
export ARCH=arm
export CROSS_COMPILE=/Volumes/Android/arm-linux-gnueabihf-osx/bin/arm-linux-gnueabihf-
export CONFIG_NEW_CC=y

if [ ! -f .config ];
then
make m0_00_defconfig
fi

nice -n 10 make -j5 || exit 1

cp -R ramdisk_samsung temp

find . -name '*.ko' -exec cp -av {} temp/lib/modules/ \;

/Volumes/Android/arm-linux-gnueabihf-osx/bin/arm-linux-gnueabihf-strip --strip-unneeded temp/lib/modules/*

find . -name \.DS_Store -exec rm -f {} \;

cd temp

find . | cpio -o -H newc | gzip > ../temp.cpio.gz

cd ..

./mkbootimg --kernel arch/arm/boot/zImage --ramdisk temp.cpio.gz --board smdk4x12 --base 0x10000000 --pagesize 2048 -o boot.img

rm -rf temp

rm temp.cpio.gz

make clean

echo "boot.img ready"
