#!/bin/bash
# rowrun.sh <runner row dir with cmds.txt> <binary> <tag>: rerun the row's slang command with
# <binary> from the row dir; writes /tmp/r11u452_scr/rows/<row>/<tag>.uhdm, prints rc and md5
d=$1; B=$2; t=$3; [ -x "$B" ] || { echo "no binary $B"; exit 2; }
r=$(basename $d); o=/tmp/r11u452_scr/rows/$r; mkdir -p $o; rm -f $o/$t.uhdm
C=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *//; s| -o .*$||' | awk -v b="$B" '{$1=b; print}')
(cd $d && eval "${ENVS} timeout 900 $C -o $o/$t.uhdm" > $o/$t.log 2>&1 </dev/null; echo $? > $o/$t.rc)
echo "$r $t rc=$(cat $o/$t.rc) md5=$(md5sum < $o/$t.uhdm | cut -c1-8)"
