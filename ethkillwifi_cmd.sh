#!/bin/bash
#Requires sudo for /sbin/iwconfig without password

desktopfinal=$HOME/.local/share/applications/ethkillwifi.desktop
STATFILE=$HOME/.ethkillwifi/ethkillwifi.status
WIFIPATH=$(ls -1d /sys/class/net/w* | head -1)
WIFICARD=$(basename $WIFIPATH)
if [[ $1 == "on" ]] ; then

	rm -f "$HOME/.ethkillwifi/ethkillwifi.disable"
	STATUS=$(cat $STATFILE)
	if [[ $STATUS == "ethernet" ]]; then
		sed -i 's/Icon=ethkilloff/Icon=ethprimary/' $desktopfinal;touch $desktopfinal
	else
		sed -i 's/Icon=ethkilloff/Icon=wifiprimary/' $desktopfinal;touch $desktopfinal
	fi
    exit 0
fi
if [[ $1 == "off" ]] ; then
	touch "$HOME/.ethkillwifi/ethkillwifi.disable"
	sed -i 's/Icon=ethprimary/Icon=ethkilloff/' $desktopfinal
	sed -i 's/Icon=wifiprimary/Icon=ethkilloff/' $desktopfinal;touch $desktopfinal
    exit 0
fi

if [[ $1 == "wifion" ]] ; then

    notify-send "EthKillWifi Monitor" "Enabling WIFI card!"

    # nmcli nm wifi on
	sudo /sbin/iwconfig $WIFICARD txpower on
    sleep 5
    #enable monitor
    rm -f "$HOME/.ethkillwifi/ethkillwifi.disable"
	STATUS=$(cat $STATFILE)
	if [[ $STATUS == "ethernet" ]]; then
		sed -i 's/Icon=ethkilloff/Icon=ethprimary/' $desktopfinal;touch $desktopfinal
	else
		sed -i 's/Icon=ethkilloff/Icon=wifiprimary/' $desktopfinal;touch $desktopfinal
	fi
    exit 0
fi

if [[ $1 == "wifioff" ]] ; then

    #disable monitor
    touch "$HOME/.ethkillwifi/ethkillwifi.disable"
	sudo /sbin/iwconfig $WIFICARD txpower off
	sed -i 's/Icon=ethprimary/Icon=ethkilloff/' $desktopfinal
	sed -i 's/Icon=wifiprimary/Icon=ethkilloff/' $desktopfinal;touch $desktopfinal

    sleep 15

    notify-send "EthKillWifi Monitor" "Disabling WIFI card!"
    # nmcli nm wifi off
	sudo /sbin/iwconfig $WIFICARD txpower off

    exit 0
fi
