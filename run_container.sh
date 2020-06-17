#!/bin/sh

readonly DIR="$(dirname -- "$0")"

readonly CONT_NAME="${1:-nswe001}"
 [ $# -gt 0 ] && shift

dev="$("$DIR"/.utils/get_usb.sh)"
echo -e "\e[33;1mDevice:\e[0m $dev" >&2

docker build -t "$CONT_NAME" .
docker run -it --rm --device=/dev/bus/usb/"$dev" "$@" "$CONT_NAME" bash
