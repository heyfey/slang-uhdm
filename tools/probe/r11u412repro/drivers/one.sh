#!/bin/bash
# one.sh <relpath.sv> <binary> <tag> : rerun the master control's (/tmp/intr11u410) slang command with <binary>, strictcmp head
r=${1%.sv}; d=/tmp/intr11u410/svtests/work/$r; o=/tmp/r11u412_scr/sv/$3/$r; mkdir -p $o; rm -f $o/slang.uhdm
g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[^) ]*' $d/cmds.txt | head -1)/golden.uhdm
cmd=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *//; s# -o [^ ]*# -o '$o'/slang.uhdm#; s#^[^ ]*slang-uhdm#'$2'#')
(cd $o && eval timeout 600 $cmd > $o/slang.log 2>&1 </dev/null; echo $? > $o/rc)
echo "$1 rc=$(cat $o/rc) $(timeout 600 /tmp/wt_r11u412/build/uhdm-strictcmp --max 2 $g $o/slang.uhdm 2>&1 | tail -1)"
