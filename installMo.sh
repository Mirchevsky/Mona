#!/usr/bin/bash
set -euo pipefail
A='.config/openbox'
B="$HOME/$A"
G='/net/launchpad/plank/docks'
H='/dock1/'
F="$HOME/.config/plank/dock1/launchers/"
mkdir -p "$B" "$F" "$HOME/.config/volumeicon"
cat > "$B/autostart" <<'AUTOSTART'
lxqt-policykit &
picom --experimental-backends &
plank &
xpad &
(sleep 2 && volumeicon) &
(sleep 2 && nm-applet) &
(sleep 2 && sh "$HOME/m.sh") &
AUTOSTART
cat > "$HOME/m.sh" <<'MSH'
dconf dump /net/launchpad/plank/docks/ > "$HOME/docks.ini"
sed -i 's/bottom/right/' "$HOME/docks.ini"
cat "$HOME/docks.ini" | dconf load /net/launchpad/plank/docks/
printf '%s\n' '[PlankDockItemPreferences]' 'Launcher=file:///usr/share/applications/nemo.desktop' > "$HOME/.config/plank/dock1/launchers/nemo.dockitem"
rm -f "$HOME/.config/plank/dock1/launchers/geeqie.dockitem" "$HOME/.config/plank/dock1/launchers/vlc-1.dockitem"
pkill volumeicon || true
[ -f "$HOME/.config/volumeicon/volumeicon" ] && sed -i -e '13,16 s/fals/tru/' -e "s/xterm -e 'alsamixer'/pavucontrol/" "$HOME/.config/volumeicon/volumeicon" || true
volumeicon &
sleep 19
rm -f "$HOME/docks.ini" "$HOME/m.sh"
MSH
chmod 755 "$HOME/m.sh"
echo -e '\e[1;31mDone, Type: reboot\e[0m'
rm -f /etc/U "$0"
