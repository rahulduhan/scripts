#!/bin/bash
################################
##Arch-Linux-Lazy-Installation##
################################
#Arch_Install
timedatectl set-ntp true
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk -l
read -p "Enter the drive's Name :  " drive
# cfdisk /dev/$drive
echo -e "g\nn\n1\n\n+300M\nn\n2\n\n\nw" | fdisk /dev/$drive
lsblk -l
read -p "Enter the name of EFI partition  :  " efipartition
mkfs.fat -F 32 /dev/$efipartition
read -p "Enter the name of Linux Partition :  " linuxpartition
mkfs.ext4 /dev/$linuxpartition
mount /dev/$linuxpartition /mnt
mkdir -p /mnt/boot/efi
mount /dev/$efipartition /mnt/boot/efi
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#genconfigs$/d' `basename "$0"` > /mnt/install_configuration.sh
chmod +x /mnt/install_configuration.sh
arch-chroot /mnt ./install_configuration.sh
exit
#genconfigs
echo "Starting General Configuration"
sleep 2
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
read -p "Enter Hostname :  " hostname
echo $hostname > /etc/hostname
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.0.1     $hostname.localdomain $hostname" >> /etc/hosts
passwd
pacman --noconfirm -S grub vim networkmanager efibootmgr bash-completion neofetch htop git
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
touch /etc/sudoers.d/install
chmod 600 /etc/sudoers.d/install
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/install
read -p "Enter Username :  " username
useradd -m -G wheel -s /bin/bash $username
passwd $username
echo "General Configuration fishished"
sleep 2
user_path=/home/$username/going_graphical.sh
sed '1,/^#going_graphical$/d' install_configuration.sh > $user_path
chown $username:$username $user_path 
chmod +x $user_path
su -c $user_path -s /bin/sh $username
exit
#going_graphical
cd $HOME
echo "I am Home"
git clone https://aur.archlinux.org/yay.git
cd paru
makepkg -si
yay --sudoloop --noconfirm --cleanafter -Sy treefetch-bin
#paru --sudoloop --noconfirm --cleanafter -Sy openbox ttf-jetbrains-mono xorg-server xorg-xinit xorg-xrandr alacritty  xfce-terminal pcmanfm obconf lxappearence librewolf-bin xfce4-terminal xorg-xrandr man-db rsync zip unzip unrar p7zip 
treefetch -b sleep 5
