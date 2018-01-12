#!/bin/bash
LINE=$(nmcli con show | tr -s " " | cut -d " " -f 4 | grep -v DEV  | grep -n '[0-9]')
if [[ ! -z "$LINE" ]] ; then
    NLINE=$(echo $LINE | cut -d: -f 1)
    CONNAME=$( nmcli con show | tr -s " " | cut -d " " -f 1 | grep -v NAME | sed -n 1p )
    echo 3 $CONNAME

    nline=$(nmcli dev show | grep -n $CONNAME | cut -d: -f 1)
    if [[ "$nline" != "" ]]; then
        
        nipline=$(echo "$nline + 2" | bc)        
        ipaddr=$(nmcli dev show | sed -n "${nipline}p" | tr -s " " |  cut -d: -f 2)
        notify-send "Kill wifi Mon" "Conn $CONNAME: Got IP $ipaddr"
    fi
    
    #zenity  --title "Active Connections" --info --text "\nActive connection: $CONNAME"
else
    zenity  --title "Active Connections" --info --text "\nNo connections active"
fi
