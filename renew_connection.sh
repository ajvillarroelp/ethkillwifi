CONNAME=$(nmcli con show | cut -d" " -f 1 | grep -v NAME | head -1)
if [[ "$CONNAME" != "" ]] ; then
    echo Renewing $CONNAME...
    nmcli con down $CONNAME
    sleep 1
    nmcli con up $CONNAME
fi
