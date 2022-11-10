#!/bin/sh

# This script assembles the DinUX_OS bootloader, kernel and programs
# with NASM, and then creates floppy and CD images (on Linux)



if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e disk_images/DinukUX_OS.flp ]
then
	echo ">>> Creating new DinUX_OS floppy image..."
	mkdosfs -C disk_images/DinUX_OS.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o source/bootloader/bootloader.bin source/bootloader/bootloader.asm || exit


echo ">>> Assembling MikeOS kernel..."

cd source
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit
cd ..


echo ">>> Assembling programs..."





echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=source/bootloader/bootloader.bin of=disk_images/DinUX_OS.flp || exit


echo ">>> Copying MikeOS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat disk_images/DinUX_OS.flp tmp-loop && cp source/kernel.bin tmp-loop/



sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_images/DinUX_OS.iso
mkisofs -quiet -V 'MIKEOS' -input-charset iso8859-1 -o disk_images/DinUX_OS.iso -b DinUX_OS.flp disk_images/ || exit

echo '>>> Done!'
