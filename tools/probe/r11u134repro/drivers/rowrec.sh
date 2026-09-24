#!/bin/bash
# rowrec.sh <row dir> [outprefix] -> strictcmp_x dumps (raw names) golden/ours + verdict
d=$1; o=${2:-/tmp/r11u134_scr/r}
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')
[ -f "$g/golden.uhdm" ] && g=$g/golden.uhdm
[ -d "$g" ] && g=$(ls $g/*.uhdm | head -1)
[ -z "$g" ] && g=$(ls $d/*/surelog.uhdm $d/golden*.uhdm 2>/dev/null | head -1)
echo "golden=$g"
/tmp/r11u134_bin/strictcmp_x --max ${3:-10} --dump-a $o.g.rec --dump-b $o.o.rec $g $d/slang.uhdm 2>&1 | tail -${4:-40}
