#!/bin/bash
# rdist.sh <golden> <ours> <tag>: strict record distance (changed lines of the canonical record walk diff); NA when stage 1 writes no records
SC=/tmp/wt_v11u449/build/uhdm-strictcmp; [ -x "$SC" ] || exit 2
t=/tmp/v11u449_scr/rd_$3; rm -f $t.a $t.b; $SC --dump-a $t.a --dump-b $t.b $1 $2 >/dev/null 2>&1
[ -s $t.a ] || { echo NA; exit; }
diff $t.a $t.b | grep -c '^[<>]'
