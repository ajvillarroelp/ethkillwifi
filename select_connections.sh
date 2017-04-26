CONLIST=$(nmcli con show | cut -d" " -f 1 | grep -v NAME)
SELECTED=$(zenity --list  \
  --title="Choose Connection" --width=400 --height=400 \
  --column="Name" \
 $CONLIST)
if [[ "$SELECTED" != "" ]] ; then
    echo "--$SELECTED--"
    nmcli con up $SELECTED
    sleep 2
    nline = $(nmcli dev show | grep -n $SELECTED | cut -d: -f 1)
    if [[ "$nline" != "" ]]; then
        nipline = $(echo "$nline + 3" | bc)
        ipaddr = $(nmcli dev show | sed -n "${nipline}p" | tr -s " " | cut -d: -f 2)
        notify-send "Kill wifi Mon" "Conn $SELECTED: Got IP $ipaddr"
    fi
fi
