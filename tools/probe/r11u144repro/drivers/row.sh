#!/bin/bash
# row.sh <row dir> [max] -> strictcmp with record dumps into <row dir>/rr
source /tmp/r11u144_env.sh
d=$(realpath $1)
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')
[ -d "$g" ] && g=$(ls $g/*.uhdm | head -1)
mkdir -p $d/rr
$STRICT_CMP --max ${2:-20} --dump-a $d/rr/g.rec --dump-b $d/rr/o.rec $g $d/slang.uhdm > $d/rr/strict.txt 2>&1
echo "golden=$g" > $d/rr/golden_path
cat $d/rr/strict.txt
