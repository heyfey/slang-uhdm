#!/bin/bash
# pacmp.sh <grid case dir> <tagA> <tagB>: the param_assign right-hand sides (pa.py, copied from r11v174repro) of golden,
# tagA and tagB side by side, as multisets; prints the lines each state holds that golden lacks and the golden-agreeing
# lines of tagA that tagB lost.  Reads only the case's own databases (r11u182).
source /tmp/wt_r11u182/tools/probe/r11u182verify/drivers/env.sh || exit 2
d=$1; A=$2; B=$3; D=$(dirname $0)
g=$(ls $d/gold_*/golden.uhdm | head -1)
for t in $g $d/$A.uhdm $d/$B.uhdm; do $UHDM_DUMP $t 2>/dev/null | python3 $D/pa.py /dev/stdin | sort > $t.pa; done
echo "$(basename $d): $A away=$(comm -23 $d/$A.uhdm.pa $g.pa | wc -l) $B away=$(comm -23 $d/$B.uhdm.pa $g.pa | wc -l) lost_by_$B=$(comm -12 $d/$A.uhdm.pa $g.pa | comm -23 - $d/$B.uhdm.pa | wc -l)"
[ -n "$V" ] && { echo "-- golden only"; comm -23 $g.pa $d/$B.uhdm.pa; echo "-- $B only"; comm -13 $g.pa $d/$B.uhdm.pa; echo "-- $A only"; comm -13 $g.pa $d/$A.uhdm.pa; }
