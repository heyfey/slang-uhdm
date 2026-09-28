#!/bin/bash
# gridall.sh [--el] <out file>: grid.py over every case of cases/ (three at a time), one output file per view.
source "$(dirname "$0")/env.sh" || exit 2
EL=""; [ "$1" = --el ] && { EL=--el; shift; }
out=$1; tmp=/tmp/r11u204_gridparts$EL; rm -rf $tmp; mkdir -p $tmp
find $R204_DIR/cases -name 'dut.sv' -printf '%h\n' | sort | grep -vwE "$(echo $FENCED | tr ' ' '|')" > $tmp/list
while read d; do echo "$d"; done < $tmp/list | xargs -P 3 -I{} bash -c 'r=$(echo {} | sed "s#.*/cases/##; s#/#_#g"); python3 '"$(dirname "$0")"'/grid.py '"$EL"' {} > '"$tmp"'/$r.txt 2>&1'
cat $tmp/*.txt > $out; echo "cases=$(wc -l < $tmp/list) results=$(grep -c ^RESULT $out)"
