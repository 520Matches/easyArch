#!/bin/bash
#
# This script is intendet to install a simple and lightweight instance of Arch Linux on Desktop and Notebook systems.
# The installation contains a setup for german language user expirience.
# A working internet connection is required.
# The installation process is splitted in two scripts. This is script 2/2 for the configuration of the base system.
#
# TODO: Install an AUR helper
# TODO: Configure a screenlocker
# TODO: Configure GRUB2 Theme and Timeout
# TODO: Setup /home and Swap encryption option

# Quit the script if any executed command fails:
set -e

# Set a new hostname
read -p "Please enter the new hostname: " hostname
echo "$hostname" > /etc/hostname

# Set the locale
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
echo zh_CN.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen

# Set the german keyboard layout to be loaded automatically
#echo KEYMAP=de-latin1 > /etc/vconsole.conf
#echo FONT=lat9w-16 >> /etc/vconsole.conf

# Set the timezone to berlin
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Update the pacman index
pacman -Sy

# Create the initramfs
mkinitcpio -p linux

# Set a new root password
echo 'Set root password:'
passwd

# Install and configure GRUB2
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

# Disable the default DHCP service
#systemctl disable dhcpcd dhcpcd@

# Create a new user
echo "Please enter your user name"
read username
useradd -m -g users -s /bin/bash "$username"

# Set the new users password
echo 'Set' "$username"'s' 'password:'
passwd "$username"

# Give the "wheel" group sudo permissions
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

# Add the user to the wheel group
gpasswd -a "$username" wheel

# Add the user to the network group
#gpasswd -a "$username" network

echo 'Done! Please restart your machine.'
