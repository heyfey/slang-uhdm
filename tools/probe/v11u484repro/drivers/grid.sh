#!/bin/bash
# grid.sh <bin> <tag> <listfile> [VAR=val...]  (list of absolute case DIRS)
B=$1; T=$2; L=$3; shift 3
for v in "$@"; do export "$v"; done
xargs -P 3 -n 1 nice -n 5 /tmp/v11u484_tools/runcase.sh "$B" "$T" < "$L" | sort
