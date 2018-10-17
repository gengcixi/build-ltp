#!/bin/bash

# build requirement tools
sudo apt-get install make 	
sudo apt-get install bison flex

TOPDIR=$(cd `dirname $0`; pwd)
OUTPUTDIR=$TOPDIR/output 
mkdir -p $OUTPUTDIR

if [ $# != 1 ]; then
    echo "please use sh opts(arm|arm64)"
    exit 0

fi

ARCH=arm
#CROSS_COMPILE=arm-linux-gnueabi-
#CROSS_COMPILE=arm-linux-androideabi-
CROSS_COMPILE=arm-linux-gnueabihf-
platform=$(echo ${CROSS_COMPILE%%-*})-linux

while [ ! -d ltp ];do
    git clone https://github.com/linux-test-project/ltp.git
done

cd ltp
git pull
git tag |tail -1 > version
git checkout -b local ${version}

make O=${OUTPUTDIR} distclean
make O=${OUTPUTDIR} autotools

./configure \
     AR=${CROSS_COMPILE}ar \
     CC=${CROSS_COMPILE}gcc \
     RANLIB=${CROSS_COMPILE}ranlib \
     STRIP=${CROSS_COMPILE}strip \
     --build=i686-pc-linux-gnu \
     --host=${platform} \
     --target=${platform} \
     --prefix=$TOPDIR/output \
     ANDROID=1

make O=$OUTPUTDIR
make O=$OUTPUTDIR install
