#!/bin/bash
# rowcmp.sh <row dir of a verify_golden workdir> [max]  -> strictcmp output (differing records)
source /tmp/r11u130_env.sh
d=$1; m=${2:-20}
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')
[ -f "$g/golden.uhdm" ] && g=$g/golden.uhdm
[ -d "$g" ] && g=$(ls $g/*.uhdm | head -1)
$STRICT_CMP --max $m --dump-a $d/g.rec --dump-b $d/o.rec $g $d/slang.uhdm 2>&1
