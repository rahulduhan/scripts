#!/bin/bash
################################
##Arch-Linux-Lazy-Installation##
################################
timedatectl set-ntp true
lsblk -l
read -p "Enter the drive's Name :  " drive
read -p "Enter Hostname :  " hostname
read -p "New root password: " rootpass
read -p "Enter Username :  " username
read -p "New user password: " userpass
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
echo -e "g\nn\n1\n\n+300M\nn\n2\n\n\nw" | fdisk /dev/$drive
mkfs.ext4 /dev/"$drive"2
mount /dev/"$drive"2 /mnt
mkfs.fat -F 32 /dev/"$drive"1
mkdir -p /mnt/boot/efi
mount /dev/"$drive"1 /mnt/boot/efi
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#genconfigs$/d' `basename "$0"` > /mnt/install_configuration.sh
chmod +x /mnt/install_configuration.sh
arch-chroot /mnt ./install_configuration.sh
exit
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo $hostname > /etc/hostname
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.0.1     $hostname.localdomain $hostname" >> /etc/hosts
echo $rootpass\n$rootpass | passwd
pacman --noconfirm -S grub vim networkmanager efibootmgr bash-completion neofetch htop git go
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
svirt manger booting from hard driveed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
touch /etc/sudoers.d/install
chmod 600 /etc/sudoers.d/install
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/install
useradd -m -G wheel -s /bin/bash $username
echo $userpass\n$userpass | passwd $username
echo "General Configuration fishished"
sleep 2
user_path=/home/$username/going_graphical.sh
sed '1,/^#going_graphical$/d' install_configuration.sh > $user_path
chown $username:$username $user_path 
chmod +x $user_path
su -c $user_path -s /bin/sh $username
exit
cd $HOME
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
yay --sudoloop --noconfirm --cleanafter -Sy treefetch-bin
treefetch -b sleep 5
