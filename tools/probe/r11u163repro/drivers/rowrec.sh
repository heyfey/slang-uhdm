#!/bin/bash
# rowrec.sh <sweepdir> <corpus> <mode> <test> [max]: the strict comparator's differing records of one
# sweep row (golden from the cache entry its cmds.txt names, ours = the row's slang.uhdm).
# FAIL-CLOSED on $FENCED: refuses to run without the four names and refuses a fenced test.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "rowrec.sh: export FENCED (four names) first" >&2; exit 1; }
W=$1; C=$2; M=$3; T=$4; N=${5:-20}
for f in $FENCED; do [ "$T" = "$f" ] && { echo "rowrec.sh: fenced test refused" >&2; exit 1; }; done
SC=${SC:-/tmp/r11u163_x/strictcmp_raw}
d=$(ls -d $W/$C/$M/$T-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "no row dir" >&2; exit 1; }
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
[ -s $d/slang.uhdm ] || { echo "no slang.uhdm (row equal or rejected)"; exit 0; }
$SC --max $N ${DA:+--dump-a $DA --dump-b $DB} $g $d/slang.uhdm
