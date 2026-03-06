#!/bin/bash
set -euo pipefail
E='-o noatime,compress=zstd,subvol='
F='btrfs subvolume create'
G='timedatectl set'
H=/etc/pacman
I="$(curl -fsSL https://ipapi.co/timezone || true)"
K=/etc/mkinitcpio.conf
R='https://raw.githubusercontent.com/Mirchevsky/Mona/main'
P='base base-devel linux linux-headers linux-firmware efibootmgr grub btrfs-progs xorg xorg-xinit sddm openbox lxqt-policykit xterm pipewire pipewire-alsa pipewire-pulse pipewire-jack gst-plugin-pipewire pavucontrol firefox chromium vim git htop alacritty rofi plank xpad xlockmore galculator volumeicon vlc obconf-qt arandr alsa-utils gvfs-afc gvfs-mtp geeqie geany-plugins nemo nemo-fileroller networkmanager network-manager-applet gufw telegram-desktop libreoffice-still otf-fira-sans otf-fira-mono pkg-config libpulse'
setfont ter-124n || true
printf ' %9s\n' | tr ' ' -
until lsblk -do NAME,SIZE -e 7,11 | grep --color=always -E '[A-Z]' && read -rp $'\e[1;31mInstallation Disk Name\e[0m→' A && B="/dev/$A" && sgdisk "$B" -Z -n 1::+512M -t 1:EF00 -n 2; do :; done
C="$(ls /dev/* | grep -E "^${B}p?1$")"
D="$(ls /dev/* | grep -E "^${B}p?2$")"
mkfs.fat -F32 "$C"
mkfs.btrfs -f "$D"
mount "$D" /mnt
cd /mnt
$F @home
$F @
cd /
umount /mnt
mount -o noatime,compress=zstd,subvol=@ "$D" /mnt
mkdir -p /mnt/{boot,home}
mount "$C" /mnt/boot
mount -o noatime,compress=zstd,subvol=@home "$D" /mnt/home
lsblk -pe 7,11 | grep --color=always -E '/?'
[ -n "$I" ] && $G-timezone "$I" || true
$G-ntp true || true
sed -i 's/^#Color/Color/' "$H.conf"
reflector --sort rate -p https --score 6 --save "$H.d/mirrorlist"
pacstrap -K /mnt $P
curl -fsSL "$R/install.sh" > /mnt/s
chmod +x /mnt/s
cp "$K" "/mnt$K"
printf '/usr/share/zoneinfo/%s\n' "$I" > /mnt/T
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt sh /s
