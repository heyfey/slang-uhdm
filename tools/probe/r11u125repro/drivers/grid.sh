#!/bin/bash
# grid.sh <grid dir> <bin tags...>
g=$1; shift
for c in $(ls -d $g/*/ | sort); do for b in "$@"; do /tmp/r11u125_scratch/case.sh $c /tmp/r11u125_bin/$b.bin $b | sed "s/^/$b /"; done; done
