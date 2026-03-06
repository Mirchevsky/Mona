#!/bin/bash
set -euo pipefail

E=' -o noatime,compress=zstd,subvol='
F='btrfs su cr'
setfont ter-124n
J="$(lscpu | grep -Eo 'AMD|Intel' | sort -u | head -n1 || true)"
K=/etc/mkinitcpio.conf
H=/etc/pacman
I="$(curl -fsSL https://ipapi.co/timezone || true)"
G='timedatectl set'

sanitize_disk() {
  printf '%s' "$1" | tr -d '\r\n[:space:]' | sed 's#^/dev/##'
}

pacman-key --populate
printf '\n%9s\n' | tr ' ' -

until
  lsblk -do NAME,SIZE -e 7,11 | grep --color=always -E '[A-Z]' &&
  read -rp $'\e[1;31mInstallation Disk Name\e[0m→' A &&
  A="$(sanitize_disk "$A")" &&
  [ -n "$A" ] &&
  B="/dev/$A" &&
  [ -b "$B" ] &&
  sgdisk "$B" -Z -n 1::+512M -t 1:EF00 -n 2
 do
  echo 'Invalid disk name. Enter something like nvme0n1 or sda.'
done

C="$(ls /dev/* | grep -E "^${B}p?1$" | head -n1)"
D="$(ls /dev/* | grep -E "^${B}p?2$" | head -n1)"

mkfs.vfat "$C"
mkfs.btrfs -fq "$D"
mount "$D" /mnt
cd /mnt
$F @home
$F @
cd /
umount /mnt
mount $E@ "$D" /mnt
mkdir -p /mnt/{boot,home}
mount "$C" /mnt/boot
mount $E@home "$D" /mnt/home
lsblk -pe 7,11 | grep -E --color=always '/mnt|/mnt/boot|/mnt/home' || true

if [ -n "${I:-}" ]; then
  $G-timezone "$I" || true
fi
$G-ntp true || true

sed -i 's/^#Color/Color/' "$H.conf" || true
reflector --sort rate -p https --score 6 --save "$H.d/mirrorlist"

pacstrap -K /mnt \
  base base-devel linux linux-headers linux-firmware \
  vim git grub efibootmgr btrfs-progs \
  xorg xorg-xinit sddm xterm \
  openbox lxqt-policykit plank rofi alacritty obconf-qt arandr xlockmore \
  pipewire pipewire-alsa pipewire-pulse pipewire-jack pavucontrol libpulse alsa-utils gst-plugin-pipewire \
  firefox chromium telegram-desktop vlc \
  networkmanager network-manager-applet gufw \
  nemo nemo-fileroller gvfs-afc gvfs-mtp geeqie \
  libreoffice-still xpad galculator geany-plugins htop volumeicon \
  otf-fira-sans otf-fira-mono pkg-config

curl -fsSL https://raw.githubusercontent.com/Mirchevsky/Mona/main/install.sh > /mnt/s
chmod +x /mnt/s
cp "$K" "/mnt$K"
if [ -n "${I:-}" ]; then
  echo "/usr/share/zoneinfo/$I" > /mnt/T
fi
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt sh /s
