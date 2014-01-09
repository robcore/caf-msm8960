#!/bin/sh

export KERNELDIR=/home/michael/android/kernels/aosp/android_kernel_htc_msm8960
export PACKAGES=/home/michael/android/kernels/aosp/packages-cm10.2.0
export MODULES=$PACKAGES/system/lib/modules
export DATE=$(date +"%A-%B-%d-%Y")
export TIME=$(date +"%r")
export CROSSARCH="arm"
export CROSSCC="$CROSSARCH-eabi-"
export TOOLCHAIN="/home/michael/android/android-toolchain-eabi/bin"

echo ""
echo "*************** Today is $DATE-$TIME, M'kay ***************"
echo ""

echo "Clean Up Package Directory"
find $MODULES -type f -exec rm {} \;
rm $PACKAGES/DIRTyMAC*.zip
rm $PACKAGES/kernel/zImage

echo "Make the kernel"
make clean
make mac_defconfig
make -j`grep 'processor' /proc/cpuinfo | wc -l`

if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	echo "Make kcontrol gpu module"
	git clone https://github.com/showp1984/kcontrol_gpu_msm.git
	cd $KERNELDIR/kcontrol_gpu_msm
	sed -i '/KERNEL_BUILD := /c\KERNEL_BUILD := ../' Makefile
	make
	cd $KERNELDIR

	echo "Copy modules to Package"
	cp -a $(find . -name *.ko -print) $MODULES
	cp kcontrol_gpu_msm/kcontrol_gpu_msm.ko $MODULES

	echo "Remove temp kcontrol directory"
	rm -rf kcontrol_gpu_msm

	echo "Copy zImage to Package"
	cp arch/arm/boot/zImage $PACKAGES/kernel/zImage

	echo "Make kernel.zip"
	export curdate=`date "+%m-%d-%Y"`
	cd $PACKAGES
	zip -r DIRTyMAC-$curdate.zip .
	cd $KERNELDIR
else
	echo "KERNEL DID NOT BUILD! no zImage exist"
fi;
