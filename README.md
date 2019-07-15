# sdRPi

Update tool for Raspberry pi SD card

## Prerequisities

Following folder structure

```bash
.
├── 01_bootloaders/
├── 02_kernel/
├── firmware/
├── linux/
├── u-boot/
├── updateSD.sh
└── README.md
```

## Usage

Usage: ./updateSD [option] [path_to_sd]"

```bash
-h, --help                 display help
-l                         List all mmcblk and sdb drives in the system 
--setupSD                  Setup SD card - create partitions etc. (Use at your own risk!)
--uboot                    Update u-boot files on SD card.
--kernel                   Update kernel files on SD card.
--rootfs                   (not implemented!)Update rootfs files on SD card.
--all                      Update u-boot, kernel and rootfs files on SD card.
```

## Usage examples

```bash
./updateSD -l
./updateSD --setupSD /dev/sdb0
./updateSD --setupSD /dev/mmcblk0
./updateSD --uboot /media/user
./updateSD --kernel /media/user
./updateSD --rootfs /media/user
./updateSD --all /media/user
./updateSD --all /media/user
```


## License
[MIT](https://choosealicense.com/licenses/mit/)
