#!/bin/bash
# away.sh <listfile> <binA> <binB> <out>: away1.sh over the list, 3 at a time
D=$(dirname "$(realpath "$0")")
xargs -a "$1" -P 3 -I{} bash $D/away1.sh {} "$2" "$3" > "$4"
