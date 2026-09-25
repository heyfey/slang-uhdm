#!/bin/bash
# rowcx.sh <corpus> <mode> <test> <tag> [max] : strict records of a row run by row.sh
c=$1; m=$2; n=$3; t=$4
d=$(ls -d /tmp/r11u145_rows/$t/$c/wd/$c/$m/$n-* 2>/dev/null | head -1)
[ -z "$d" ] && d=$(ls -d /tmp/r11u145_rows/$t/$c/wd/$m/$n-* | head -1)
g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
/tmp/r11u145_s/ctx2.sh $g $d/slang.uhdm ${5:-6} ${6:-0}
