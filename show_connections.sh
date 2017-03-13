#!/bin/bash
LINE=$(nmcli con show | tr -s " " | cut -d " " -f 4 | grep -v DEV  | grep -n '[0-9]')
if [[ ! -z "$LINE" ]] ; then
    NLINE=$(echo $LINE | cut -d: -f 1)
    CONNAME=$( nmcli con show | tr -s " " | cut -d " " -f 1 | grep -v NAME | sed -n 1p )
    echo 3 $CONNAME
    zenity  --title "Active Connections" --info --text "\nActive connection: $CONNAME"
else
    zenity  --title "Active Connections" --info --text "\nNo connections active"
fi
