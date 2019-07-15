#!/bin/sh
# Setup raspberry pi sd card and copy u-boot, kernel and rootfs files into it

###
# The command line help
###
display_help() {
    echo "Description: Setup raspberry pi sd card and copy u-boot, kernel and rootfs files into it"
    echo
    echo "Prerequisities: "
    echo "  -Following folder structure:"
    echo "                                        dir
         ________________________________|___________________________ 
        |              |             |         |          |          |
  01_bootloaders/   02_kernel/    firmware/   linux/    u-boot/   updateSD.sh"

    echo
    echo "Usage: $0 [option] [path_to_sd]"
    echo
    echo "   -h, --help                 display help"
    echo "   -l                         List all mmcblk and sdb drives in the system "
    echo "   --setupSD                  Setup SD card - create partitions etc. (Use at your own risk!)"
    echo "   --uboot                    Update u-boot files on SD card. "
    echo "   --kernel                   Update kernel files on SD card. "
    echo "   --rootfs                   (not implemented!)Update rootfs files on SD card. "
    echo "   --all                      Update u-boot, kernel and rootfs files on SD card. "
    echo
    echo "Usage examples: "
    echo "   ./updateSD -l"
    echo "   ./updateSD --setupSD /dev/sdb0"
    echo "   ./updateSD --setupSD /dev/mmcblk0"
    echo "   ./updateSD --uboot /media/user"
    echo "   ./updateSD --kernel /media/user"
    echo "   ./updateSD --rootfs /media/user"
    echo "   ./updateSD --all /media/user"
    echo
    exit 0
}

###
# Search for SD cards
###
run_lsblk() {
  echo "Searching for mmcblk and sdb drives..."
  lsblk | grep 'mmcblk\|sdb'
}

###
# Check if the directory exists
###
check_dir() {
  # Save argument directory to global variable
  DIRECTORY="$1"
  DIRECTORY_BOOT="$1/boot"
  DIRECTORY_ROOT="$1/root"
  DIRECTORY_UBOOT="$1/uboot"

  # Check if directory exists
  if [ ! -d "$DIRECTORY" ]; then
    echo "ERROR: Media not found"
    exit 2
  else
    echo
    echo $DIRECTORY " selected."
    echo
  fi
}

###
# Check if the directory exists
###
check_dir_dev() {
  # Save argument directory to global variable
  DIRECTORY="$1"

  # Check if directory exists
  if [ ! -e "$DIRECTORY" ]; then
    echo "ERROR: Media not found"
    exit 2
  else
    echo
    echo $DIRECTORY " selected."
    echo
  fi
}

###
# Setup SD card
###
setup_sd() {
  read -p "Are you sure that the path is correct? (y/n) " yn
  case $yn in
      [Yy]* ) echo "Setting up...";;
      [Nn]* ) exit 2;;
      * ) echo "Please answer yes or no.";;
  esac
  PARTS="p*"
  PARTS1="p1"
  PARTS2="p2"
  PARTS3="p3"
  sudo umount $DIRECTORY$PARTS
  sudo parted -s $DIRECTORY mklabel msdos \
  mkpart primary fat32 1M 30M \
  mkpart primary ext4 30M 1G \
  mkpart primary ext4 1G 100% \
  set 1 boot on

  sudo mkfs.vfat -n "uboot" $DIRECTORY$PARTS1
  sudo mkfs.ext4 -L "boot" $DIRECTORY$PARTS2
  sudo mkfs.ext4 -L "root" $DIRECTORY$PARTS3

  echo "Finished!"
}

###
# Copy u-boot files
###
copy_uboot() {
  echo "Checking uboot partition..."
  # Check if directory exists
  if [ ! -d "$DIRECTORY_UBOOT" ]; then
    echo "ERROR: Media not found"
    exit 2
  fi
  echo "Updating U-boot files on SD card..."
  echo "Copying u-boot.bin"
  sudo cp u-boot/u-boot.bin $DIRECTORY_UBOOT
  echo "Copying bootcode.bin"
  sudo cp firmware/boot/bootcode.bin $DIRECTORY_UBOOT
  echo "Copying fixup.dat"
  sudo cp firmware/boot/fixup.dat $DIRECTORY_UBOOT
  echo "Copying start.elf"
  sudo cp firmware/boot/start.elf $DIRECTORY_UBOOT
  echo "Copying config.txt"
  sudo cp 02_kernel/config.txt $DIRECTORY_UBOOT

  echo "Finished!"
  echo
}

###
# Copy kernel files
###
copy_kernel() {
  echo "Checking boot partition..."
  # Check if directory exists
  if [ ! -d "$DIRECTORY_BOOT" ]; then
    echo "ERROR: Media not found"
    exit 2
  fi
  echo "Updating kernel files on SD card..."
  echo "Copying zImage"
  sudo cp linux/arch/arm/boot/zImage $DIRECTORY_BOOT
  echo "Copying bcm2710-rpi-3-b.dtb"
  sudo cp linux/arch/arm/boot/dts/bcm2710-rpi-3-b.dtb $DIRECTORY_BOOT

  echo "Finished!"
  echo
}

###
# Copy rootfs files
###
copy_rootfs() {
  echo "Checking root partition..."
  # Check if directory exists
  if [ ! -d "$DIRECTORY_ROOT" ]; then
    echo "ERROR: Media not found"
    exit 2
  fi
  # This will be changed in the future
  sudo tar xf 02_kernel/rootfs.tar -C $DIRECTORY_ROOT
  # Kernel modules will be added in the future
  echo "Finished!"
  echo
}

###
# Copy all files - u-boot, kernel, rootfs
###
copy_all() {
  copy_uboot
  copy_kernel
  copy_rootfs
}


# Check if the number of arguments is correct
if [ $# -gt 2 ]; then
  echo "ERROR: Number of arguments incorrect"
  exit 1
elif [ $# -eq 0 ]; then
  display_help
else
  case $1 in 
    -h) display_help ;; 
    h) display_help ;;
    help) display_help ;;
    -help) display_help ;;
    --help) display_help ;;
    -l) run_lsblk ;;
    --setupSD)  run_lsblk
                check_dir_dev $2 
                setup_sd ;;
    --uboot) check_dir $2 
             copy_uboot ;;
    --kernel) check_dir $2 
             copy_kernel ;;
    --rootfs) check_dir $2 
             copy_rootfs ;;
    --all) check_dir $2 
             copy_all ;;
  esac
fi

exit 0
