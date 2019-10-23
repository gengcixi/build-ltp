#!/bin/bash

# build requirement tools
sudo apt-get install make 	
sudo apt-get install bison flex

TOPDIR=$(cd `dirname $0`; pwd)
OUTPUTDIR=$TOPDIR/output 
mkdir -p ${OUTPUTDIR}/$1

# check return error
check_err()
{
    if [ $? -ne 0 ]; then
        echo Error: $* >&2
        exit 2
    fi
}

if [ $# != 1 ]; then
    echo "please use sh opts(arm|arm64)"
    exit 0

fi

if [ $1=arm ];then
    ARCH=arm
    #CROSS_COMPILE=arm-linux-gnueabi-
    #CROSS_COMPILE=arm-linux-androideabi-
    CROSS_COMPILE=arm-linux-gnueabihf-
elif [ $=arm64 ];then
    ARCH=arm64
    CROSS_COMPILE=aarch64-linux-gnu-
fi
platform=$(echo ${CROSS_COMPILE%%-*})-linux

while [ ! -d ltp ];do
    git clone https://github.com/linux-test-project/ltp.git
done

cd ltp
git pull
git branch -D local
version=`git tag |tail -1`
echo $version
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
	--prefix=${OUTPUTDIR}/$1 \
	ANDROID=1

	check_err "Failed to configure ltp!"


make O=$OUTPUTDIR/$1
check_err "Failed to build ltp!"
make O=$OUTPUTDIR/$1 install
check_err "Failed to install ltp!"
