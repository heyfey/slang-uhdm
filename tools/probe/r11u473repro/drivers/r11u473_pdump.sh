#!/bin/bash
# path-normalized dump compare of one probe database: ours (law sweep) vs the master's control
source /tmp/r11u473_env.sh; [ -x "$UHDM_DUMP" ] || exit 9
f=$1; A=${2:-/tmp/r11u473_sw/probe}; B=${3:-/tmp/intr11u471/probe}
n(){ $UHDM_DUMP "$1" 2>&1 | sed 's#/tmp/wt_r11u473#ROOT#g; s#/home/heyfey/git-repos/slang-uhdm#ROOT#g; s#/tmp/r11u473_sw#WD#g; s#/tmp/intr11u471#WD#g' | tail -n +2 | md5sum; }
a=$(n $A/$f); b=$(n $B/${4:-$f})
[ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
