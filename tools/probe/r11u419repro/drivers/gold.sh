#!/bin/bash
# r11u419 gold.sh <rowdir>: the golden uhdm path of a runner row (kept or cached)
d=$1; [ -f $d/slpp_all/surelog.uhdm ] && { echo $d/slpp_all/surelog.uhdm; exit; }
c=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' $d/cmds.txt | head -1); f=$(find $c -name '*.uhdm' | head -1); echo $f
