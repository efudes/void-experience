#!/bin/sh
set -u

export LC_ALL=C

status=$(
    nmcli -t -f TYPE,STATE,CONNECTION device status 2>/dev/null |
        awk -F: '$2 == "connected" { print $1 "|" $3; exit }'
)

type=${status%%|*}
connection=${status#*|}

case "$type" in
    wifi)
        icon=network-wireless-signal-excellent-symbolic
        label="Wi-Fi: $connection"
        ;;
    ethernet)
        icon=network-wired-symbolic
        label="Ethernet: $connection"
        ;;
    *)
        icon=network-offline-symbolic
        label="Network disconnected"
        ;;
esac

label=$(printf '%s' "$label" |
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

printf '<icon>%s</icon><iconclick>nm-connection-editor</iconclick><tool>%s</tool>\n' \
    "$icon" "$label"
