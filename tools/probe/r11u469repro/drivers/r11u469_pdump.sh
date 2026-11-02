#!/bin/bash
# path-normalized dump compare of one probe database: ours (law sweep) vs the control
source /tmp/r11u469_env.sh; [ -x "$UHDM_DUMP" ] || exit 9
f=$1
a=$($UHDM_DUMP /tmp/r11u469_sw/probe/$f 2>&1 | sed 's#/tmp/wt_r11u469#ROOT#g; s#/home/heyfey/git-repos/slang-uhdm#ROOT#g; s#/tmp/r11u469_sw#WD#g; s#/tmp/intr11u467#WD#g' | md5sum)
b=$($UHDM_DUMP /tmp/intr11u467/probe/$f 2>&1 | sed 's#/tmp/wt_r11u469#ROOT#g; s#/home/heyfey/git-repos/slang-uhdm#ROOT#g; s#/tmp/r11u469_sw#WD#g; s#/tmp/intr11u467#WD#g' | md5sum)
[ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
