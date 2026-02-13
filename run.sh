#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
    echo "Error: This script must be run as root."
    echo "Please re‑run with sudo or as the root user."
    exit 1
fi

echo "Warning: This script will make serious system changes and could cause system instabilities."
echo "If you don't know what you're doing, you should not continue!"
read -rp "Type \"Yes, do as I say!\" to continue: " answer
if [[ "${answer,,}" != "yes, do as i say!" ]]; then
    echo "Aborted – you did not answer \"Yes, do as I say!\"."
    exit 1
fi

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

apt update
apt install -y gnome-software
apt install -y flatpak
apt install -y gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
snap remove firefox --purge
snap remove snap-store --purge
snap remove gtk-common-themes --purge
flatpak update
flatpak --system install -y flathub com.brave.Browser
flatpak --system install -y flathub io.missioncenter.MissionCenter
apt purge -y gnome-system-monitor
mv $SCRIPT_DIR/arcmenu@arcmenu.com /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com
mv $SCRIPT_DIR/dash-to-panel@jderose9.github.com /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
chown -R root:root /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com
chmod -R 755 /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com
chown -R root:root /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
chmod -R 755 /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
mkdir -p /etc/dconf/db/local.d
mv $SCRIPT_DIR/00_local_settings /etc/dconf/db/local.d/00_local_settings
mv $SCRIPT_DIR/local /etc/dconf/profile/local

ENV_FILE="/etc/environment"
TARGET_LINE="DCONF_PROFILE=local"

if [[ ! -e "$ENV_FILE" ]]; then
    touch "$ENV_FILE"
    chmod 644 "$ENV_FILE"
fi

if grep -Fxq "$TARGET_LINE" "$ENV_FILE"; then
    echo "$TARGET_LINE already present in $ENV_FILE"
else
    echo "" >> "$ENV_FILE"
    echo "$TARGET_LINE" >> "$ENV_FILE"
    echo "Added $TARGET_LINE to $ENV_FILE"
fi

rm -rf /usr/share/gnome-shell/extensions/ubuntu-dock@ubuntu.com
dconf update
mv $SCRIPT_DIR/papirus-icons /usr/share/papirus-icons
rm -rf /usr/share/icons
mv $SCRIPT_DIR/icons /usr/share/icons
reboot
