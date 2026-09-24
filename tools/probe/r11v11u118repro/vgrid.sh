#!/usr/bin/env bash
# usage: vgrid.sh <outroot> <pristine bin> <law bin> <arm dir>...   (3 jobs; list fed on fd 3)
set -u
O=$1; BP=$2; BL=$3; shift 3
D=$(cd "$(dirname "$0")" && pwd)
printf '%s\n' "$@" > "$O.list"
xargs -P 3 -I{} bash -c 'a={}; bash '"$D"'/varm.sh "$a" '"$O"'/$(basename "$a") '"$BP"' '"$BL"' </dev/null' < "$O.list" | sort
echo "LISTED=$(wc -l < "$O.list")"
