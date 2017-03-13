#!/bin/bash

#desktopfrom=/usr/share/applications/dr.desktop
#desktopfinal=$HOME/$client.desktop
desktopfinal=$HOME/.local/share/applications/ethkillwifi.desktop
planklauncher=$HOME/.config/plank/dock1/launchers/ethkillwifi.dockitem
#planklauncher=$HOME/$client.dockitem

echo "[Desktop Entry]
Name=Kill wifi Monitor
GenericName=Kill wifi Monitor
Comment=Kill wifi Monitor
Exec=/bin/false
Terminal=false
Type=Application
Icon=ethkilloff
Categories=Network;FileTransfer;
StartupNotify=false
X-Ayatana-Desktop-Shortcuts=Show_Mon;Select_Mon;Disable_Mon;Enable_Mon;DisableWifi;EnableWifi

[Show_Mon Shortcut Group]
Name=Show Connection
Exec=bash /home/antonio/.ethkillwifi/show_connections.sh
TargetEnvironment=Unity

[Select_Mon Shortcut Group]
Name=Select Connection
Exec=bash /home/antonio/.ethkillwifi/select_connections.sh
TargetEnvironment=Unity

[Disable_Mon Shortcut Group]
Name=Disable Monitor
Exec=bash /home/antonio/.ethkillwifi/ethkillwifi_cmd.sh off
TargetEnvironment=Unity

[Enable_Mon Shortcut Group]
Name=Enable Monitor
Exec=bash /home/antonio/.ethkillwifi/ethkillwifi_cmd.sh on
TargetEnvironment=Unity

[DisableWifi Shortcut Group]
Name=Disable Wifi
Exec=bash /home/antonio/.ethkillwifi/ethkillwifi_cmd.sh wifioff
TargetEnvironment=Unity

[EnableWifi Shortcut Group]
Name=Enable Wifi
Exec=bash /home/antonio/.ethkillwifi/ethkillwifi_cmd.sh wifion
TargetEnvironment=Unity
" > "$desktopfinal"

echo "[PlankItemsDockItemPreferences]
Launcher=file://$desktopfinal"> "$planklauncher"

#mkdir ~/.icons
cp *.png ~/.icons
