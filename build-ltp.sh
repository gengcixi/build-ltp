#!/bin/bash

# build requirement tools
#sudo apt-get install make 	
#sudo apt-get install bison flex

TOPDIR=$(cd `dirname $0`; pwd)
OUTPUT=${TOPDIR}/output/$1
mkdir -p ${OUTPUT}

# check return error
check_err()
{
	if [ $? -ne 0 ]; then
		echo -e "\033[31m FAIL: $* \033[0m" >&2
		return_val=1
		return
	else
		echo -e "\033[33m PASS: $* \033[0m" >&2
		return_val=0
	fi
}

if [ "$1" ] ; then
	ARCH=$1
	case $1 in
		arm)
			ARCH=arm
			CROSS_COMPILE=arm-linux-gnueabihf-
			;;
		arm64)
			ARCH=arm64
			CROSS_COMPILE=aarch64-linux-gnu-
			;;
		*)
			echo "Can't find the architectrue: ${ARCH}"
			exit 0
			;;
	esac
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
#cd ltp
#git pull
#git branch -D local
#version=`git tag |tail -1`
#echo $version
#git checkout -b local ${version}

function build_ltp()
{
	echo "======= start build ltp ======="
	cd $TOPDIR/ltp
	make O=${OUTPUT}/ltp distclean >/dev/null 2>&1
	make O=${OUTPUT}/ltp autotools

    echo -e "\033[31m ${platform} \033[0m" >&2
    echo -e "\033[31m ${CROSS_COMPILE} \033[0m" >&2

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
	check_err "Configure ltp!"
	if [ ${return_val} -eq 0 ]; then
		make O=${OUTPUT}/ltp
		check_err "Build ltp!"
	fi
	if [ ${return_val} -eq 0 ]; then
		make O=${OUTPUT}/ltp install
		check_err "Install ltp!"
		if [ ${return_val} -eq 0 ]; then
			echo "======= build ltp done ======="
		fi
	fi
	make O=${OUTPUT}/ltp distclean >/dev/null 2>&1
	find ./* -maxdepth 1 -name "conf*" -type d |xargs rm -rf
	cd ${TOPDIR}
}
build_ltp

