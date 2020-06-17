#!/bin/sh

dev="$(lsusb | grep "STMicroelectronics ST-LINK/V2.1" | cut -d : -f1 | sed "s= Device =/=" | sed "s/^Bus //")"
if [ $(echo "$dev" | wc -l) -ne 1 ]; then
	echo -e "\e[31;1mWARNING:\e[0m More STM devices connected via usb." >&2
	dev="$(echo "$dev" | head -n1)"
fi

echo "$dev"
