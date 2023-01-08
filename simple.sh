# Set variables for the installation
ROOT_PARTITION="/dev/vda1"
BOOT_PARTITION="/dev/vda2"
HOSTNAME="my-arch-system"

# Create the partitions
parted -s $ROOT_PARTITION mklabel msdos
parted -s $ROOT_PARTITION mkpart primary ext4 1MiB 100%
parted -s $ROOT_PARTITION set 1 boot on
parted -s $BOOT_PARTITION mklabel msdos
parted -s $BOOT_PARTITION mkpart primary ext2 1MiB 100%
parted -s $BOOT_PARTITION set 1 boot on

# Format the partitions
mkfs.ext4 $ROOT_PARTITION
mkfs.ext2 $BOOT_PARTITION

# Mount the root partition
mount $ROOT_PARTITION /mnt

# Create a boot directory and mount the boot partition
mkdir /mnt/boot
mount $BOOT_PARTITION /mnt/boot

# Install the base system
pacstrap /mnt base

# Generate an fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Change the hostname
echo $HOSTNAME > /mnt/etc/hostname

# Set the time zone
ln -sf /usr/share/zoneinfo/Europe/Paris /mnt/etc/localtime

# Generate the locale
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt locale-gen

# Set the root password
arch-chroot /mnt passwd

# Install the bootloader
arch-chroot /mnt bootctl install

# Create the bootloader configuration file
cat > /mnt/boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=$ROOT_PARTITION rw
EOF

# Set the default boot entry
cat > /mnt/boot/loader/loader.conf <<EOF
default arch
timeout 1
EOF

# Unmount the partitions
umount /mnt/boot
umount /mnt

# Reboot the system
reboot
