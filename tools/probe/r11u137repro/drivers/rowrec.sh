#!/bin/bash
# rowrec.sh <row dir> [max] -> raw differing records golden/ours
d=$(realpath $1)
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')
[ -f "$g/golden.uhdm" ] && g=$g/golden.uhdm
[ -d "$g" ] && g=$(ls $g/*.uhdm | head -1)
[ -z "$g" ] && g=$(ls $d/*/surelog.uhdm $d/golden*.uhdm 2>/dev/null | head -1)
mkdir -p $d/rr; ln -sf $g $d/rr/golden.uhdm; ln -sf $d/slang.uhdm $d/rr/O.uhdm
/tmp/r11u137_scr/raw.sh $d/rr O ${2:-20}
