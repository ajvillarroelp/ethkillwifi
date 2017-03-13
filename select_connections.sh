CONLIST=$(nmcli con show | cut -d" " -f 1 | grep -v NAME)
SELECTED=$(zenity --list  \
  --title="Choose Connection" --width=400 --height=400 \
  --column="Name" \
 $CONLIST)
if [[ "$SELECTED" != "" ]] ; then
    echo "--$SELECTED--"
    nmcli con up $SELECTED
fi
