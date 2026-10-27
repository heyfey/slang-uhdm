#!/bin/bash
# simrow.sh <relpath-without-.sv>: simulate laws A + F2 on the control DB and localize remaining failures
r=$1; W=/tmp/intr11u444/svtests/work/$r; [ -f $W/slang.uhdm ] || { echo "$r NODB"; exit; }
g=$(grep -o 'golden cache hit [^)]*' $W/cmds.txt | awk '{print $4}')/golden.uhdm
k=$(echo $r | tr / _); o=/tmp/r11u446_s/sim/$k; mkdir -p $o
/tmp/r11u446_tools/fixer $W/slang.uhdm $o/a.uhdm > /dev/null 2>&1
/tmp/r11u446_tools/fx $o/a.uhdm $o/ab.uhdm B > /dev/null 2>&1
/tmp/r11u446_tools/clsloc $g $o/ab.uhdm ALL x > $o/loc.txt 2>&1
rm -f $o/a.uhdm
echo "$r $(grep -c '^func\|^pkgfunc\|^pkgshallow\|^module\|^design' $o/loc.txt) $(grep -v '^   ' $o/loc.txt | grep -v failures | awk '{print $1}' | sort | uniq -c | tr '\n' ' ')"
