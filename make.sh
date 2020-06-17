#!/bin/sh

readonly DIR="$(dirname -- "$0")"

readonly NAME="$1"
[ -z "$NAME" ] && echo "make.sh: Project name must be provided." >&2 && exit 2
shift
readonly COMMAND="$1"
readonly CONT_NAME="nswe001"
[ $# -gt 0 ] && shift 1

dev="$("$DIR"/.utils/get_usb.sh)"
echo -e "\e[33;1mDevice:\e[0m $dev" >&2

docker build -t "$CONT_NAME" .
docker run -it --rm --device=/dev/bus/usb/"$dev" "$@" "$CONT_NAME" bash -c "cd '$NAME' && make $COMMAND"
