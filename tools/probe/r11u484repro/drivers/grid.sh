#!/bin/bash
# grid.sh <bin> <tag> <listfile> [VAR=val...]
B=$1; T=$2; L=$3; shift 3
for v in "$@"; do export "$v"; done
xargs -P 2 -n 1 nice -n 5 /tmp/wt_r11u484/tools/probe/r11u484repro/drivers/runcase.sh "$B" "$T" < "$L" | sort
