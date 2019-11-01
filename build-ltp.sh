#!/bin/bash

# build requirement tools
#sudo apt-get install make 	
#sudo apt-get install bison flex

TOPDIR=$(cd `dirname $0`; pwd)
OUTPUT=$TOPDIR/output 
mkdir -p $OUTPUT

#if [ $# != 1 ]; then
#    echo "please use sh opts(arm|arm64)"
#    exit 0
#
#fi

if [ "$1" ] ; then
	ARCH=$1
else
	echo "please appoint the architecture:	"
	echo "1. arm "
	echo "2. arm64 "
	read ar
	case $ar in
		arm)
			ARCH=arm
			CROSS_COMPILE=arm-linux-gnueabihf-
			;;
		arm64)
			ARCH=arm64
			CROSS_COMPILE=aarch64-linux-gnu-
			;;
		1)
			ARCH=arm
			CROSS_COMPILE=arm-linux-gnueabihf-
			;;
		2)
			ARCH=arm64
			CROSS_COMPILE=aarch64-linux-gnu-
			;;
		*)
			echo "Can't find the architectrue: ${ARCH}"
			exit 0
			;;
	esac
fi

platform=$(echo ${CROSS_COMPILE%%-*})-linux

while [ ! -d ltp ];do
    git clone https://github.com/linux-test-project/ltp.git
done

function build_ltp()
{
	echo "======= start build ltp ======="
	cd $TOPDIR/ltp
	make O=${OUTPUT}/ltp distclean
	make O=${OUTPUT}/ltp autotools

	echo ${platform}
	./configure \
		AR=${CROSS_COMPILE}ar \
		CC=${CROSS_COMPILE}gcc \
		RANLIB=${CROSS_COMPILE}ranlib \
		STRIP=${CROSS_COMPILE}strip \
		--build=i686-pc-linux-gnu \
		--host=${platform} \
		--target=${platform} \
		--prefix=${OUTPUT}/ltp \
		ANDROID=1

	make O=${OUTPUT}/ltp -j $JOBS
	make O=${OUTPUT}/ltp install
	make O=${LTP_OUTPUT} distclean
	find ./* -maxdepth 1 -name "conf*" -type d |xargs rm -rf
	echo "======= build ltp done ======="
	cd ${TOPDIR}
}
build_ltp
