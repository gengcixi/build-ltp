#!/bin/bash

# build requirement tools
#sudo apt-get install make 	
#sudo apt-get install bison flex
#sudo apt-get install automake autoconf m4

TOPDIR=$(cd `dirname $0`; pwd)
TOP_SRCDIR=${TOPDIR}/ltp
TOP_BUILDDIR=${TOPDIR}/build
OUTPUT=${TOPDIR}/output/$1

#SYSROOT=rootfs_path

# check return error
check_err()
{
    if [ $? -ne 0 ]; then
        echo -e "\033[31m Error: $* \033[0m" >&2
        return_val=1
    else
        echo -e "\033[31m PASS: $* \033[0m]]" >&2
        return_val=0
    fi
}

if [ -d ${OUTPUT}} ];then
	rm -rf ${OUTPUT}
fi
if [ -d ${TOP_BUILDDIR} ];then
	rm -rf ${TOP_BUILDDIR}
fi
mkdir -p ${TOP_BUILDDIR}
mkdir -p ${OUTPUT}

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

while [ ! -d ltp ];do
    git clone https://github.com/linux-test-project/ltp.git
done
#cd ltp
#git pull
#git branch -D local
#version=`git tag |tail -1`
#echo $version
#git checkout -b local ${version}

platform=$(echo ${CROSS_COMPILE%%-*})-linux
config_ltp()
{
	cd ${TOP_SRCDIR}
	make autotools
	cd ${TOP_BUILDDIR}
	${TOP_SRCDIR}/configure  \
		AR=${CROSS_COMPILE}ar \
		CC=${CROSS_COMPILE}gcc \
		RANLIB=${CROSS_COMPILE}ranlib \
		STRIP=${CROSS_COMPILE}strip \
		--build=i686-pc-linux-gnu \
		--host=${platform} \
		--target=${platform} \
		--prefix=${OUTPUT}/ltp 
}
build_ltp()
{
	make \
		-C "${TOP_BUILDDIR}" \
		-f "${TOP_SRCDIR}/Makefile" \
		"top_srcdir=$TOP_SRCDIR" \
		"top_builddir=$TOP_BUILDDIR" 

	check_err "Failed to build ltp!"
	make \
		-C "${TOP_BUILDDIR}" \
		-f "${TOP_SRCDIR}/Makefile" \
		"top_srcdir=${TOP_SRCDIR}" \
		"top_builddir=${TOP_BUILDDIR}" \
		SKIP_IDCHECK=[1] \
		install
}

config_ltp
check_err "config ltp"
if [ ${return_val} -eq 0 ];then
    build_ltp
    check_err "build ltp"
fi

