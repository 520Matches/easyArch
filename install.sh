#!/bin/bash
#
# This script is intendet to install a simple and lightweight instance of Arch Linux on Desktop and Notebook systems.
# The installation contains a setup for german language user expirience.
# A working internet connection is required.
# The installation process is splitted in two scripts. This is script 1/2 for the installation of the base system. Script 2/2 will be copied to the hard drive and executed automatically.
# TODO: Setup Full Disk Encryption option

# Quit the script if any executed command fails:
set -e

# Set german keyboard layout
#loadkeys de

# Select the disk for the installation
echo "On which disk do you want to install Arch Linux?"
echo 'You can just type i.e. "sda"'
lsblk
read -p "Disk:" disk

# Wipe the disk
sgdisk /dev/"$disk" -o
# Create the partition table
echo "Creating GPT table..."
parted /dev/"$disk" mklabel gpt --script
echo "Success!"

# Create the boot partition (always 512MB)
echo "Creating boot partition..."
parted /dev/"$disk" mkpart BOOT fat32 1MiB 513MiB
echo "Success!"

# Create the root partiton dynamically after the Swap partition
echo "Creating root partition..."
parted /dev/"$disk" mkpart p_arch ext4 514MiB 100%
echo "Success!"

# Set the boot disk as an EFI device
echo "Setting /dev/"$disk" as EFI device..."
parted /dev/"$disk" set 1 esp on
echo "Success!"

# Create the file systems for the new partitions
mkfs.ext4 -L p_arch /dev/"$disk"2
mkfs.fat -F 32 -n BOOT /dev/"$disk"1

# Mount the newly created partitons
mount /dev/"$disk"2 /mnt
mkdir /mnt/boot
mount /dev/"$disk"1 /mnt/boot

# Configure and update the pacman index
#cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
#grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist
pacman -Sy

# Install the base system
pacstrap /mnt base base-devel linux linux-firmware iwd dhcp dhcpcd wpa_supplicant grub acpid xorg xorg-drivers alsa-utils pulseaudio pulseaudio-alsa wireless_tools networkmanager network-manager-applet sudo linux-headers dosfstools efibootmgr git gcc net-tools vim neovim make xorg-xinit fcitx fcitx-configtool curl wget openntpd xpdf

# Automatically generate the fstab file from the mount configuration
genfstab -Lp /mnt > /mnt/etc/fstab

# Copy the second file for the advanced config process to the hdd
cp ./install2.sh /mnt

# Switch to the newly installed system and run the second file
arch-chroot /mnt /install2.sh
