#!/bin/bash
set -euo pipefail
cat <<'ART'
#8' 8888
#d8.-=. ,==-.:888b
#>8 `~` :`~' d8888
#88 ,88888
#88b. `-~ ':88888
#888b ~==~ .:88888
#88888o--:':::8888
#`88888| :::' 8888b
#8888^^' 8888b
#d888 ,%888b.
#d88% %%%8--'-.
#/88:.__ , _%-' --- -
#'''::===..-' = --.
ART
A='\e[1;31m'; B='\e[0m'; C='en_US.UTF'; D='/Adwaita/Oranchelo'; E='Fira Sans Condensed Book/'; F='/Cantarell'; G='systemctl enable'; H='openbox-session'; I='/usr/share/gtk'; R='https://raw.githubusercontent.com/Mirchevsky/Mona/main/installMo.sh'
until printf "${A}Enter User Name:${B} " && read -r RUSER && U=${RUSER,,} && [ ${#U} -gt 1 ] && [[ "$U" =~ ^[a-z][a-z0-9_-]*$ ]]; do :; done
useradd -m -G wheel "$U"
HOME_DIR="$(eval echo "~$U")"
printf '%s\n' "$HOME_DIR/" > /etc/U
until printf "${A}Enter User's Password:${B} " && passwd "$U"; do :; done
until printf "Enter Root ${A}(Admin)${B} Password: " && passwd; do :; done
cat >> /etc/hosts <<HOSTS
127.0.0.1 localhost
::1 localhost
127.0.1.1 ${U}-pc.localdomain ${U}-pc
HOSTS
sed -i 's/auto/1920x1080/' /etc/default/grub || true
echo LANG=${C}-8 > /etc/locale.conf
sed -i "s/twm/$H/" /etc/X11/xinit/xinitrc || true
echo "${U}-pc" > /etc/hostname
[ -s /T ] && ln -sf "$(cat /T)" /etc/localtime
sed -i "s/#${C}/${C}/" /etc/locale.gen
hwclock --systohc
locale-gen
sed -i '0,/^# %wheel ALL=(ALL:ALL) ALL/s//%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "$H" > "$HOME_DIR/.xinitrc"
sed -i -e "s|$F|/$E|" -e "2 s|$D||" -e "s|$D-Beka||" "$I-2.0/gtkrc" || true
sed -i -e "s|$F|/$E|" -e "3 s|$D||" -e "2 s|$D-Beka||" "$I-3.0/settings.ini" || true
echo -e "${A}→ SDDM${B}"; $G sddm
echo -e "${A}→ NETWORK${B}"; $G NetworkManager
echo -e "${A}→ GRUB${B}"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
cat > /usr/share/sddm/scripts/Xsetup <<'XSETUP'
M=$(find /home/*/.screenlayout/*.sh 2>/dev/null | head -n1)
P=$(xrandr | grep -Ec 'HDMI|eDP')
O=$(xrandr | grep -oE 'eDP-1|eDP1' | head -n1)
N=$(xrandr | grep -oE 'HDMI1|HDMI-1' | head -n1)
if [ -r "$M" ] && grep -q xrandr "$M"; then
  sh "$M"
elif [ "${P:-0}" -ge 2 ] && [ -n "${N:-}" ] && [ -n "${O:-}" ]; then
  xrandr --output "$N" --pos 1920x0 --primary --output "$O" --mode 1920x1080 --pos 0x0
fi
XSETUP
cd /
chown root:root /home
chmod 755 /home
rm -f /T /s
runuser --login "$U" --session-command "sh -c 'curl -fsSL $R | bash'"
