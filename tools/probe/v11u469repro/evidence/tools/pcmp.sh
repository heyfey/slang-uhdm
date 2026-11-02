#!/bin/bash
# pcmp.sh <file>: path-normalized uhdm-dump of the law and control probe databases; prints the name when they differ
source /tmp/v11u469_env.sh; [ -x "$UHDM_DUMP" ] || exit 1
f=$1
a=$($UHDM_DUMP /tmp/v11u469_sw/probe/$f 2>/dev/null | sed -e 's#/tmp/v11u469_sw#WD#g' -e 's#/tmp/wt_v11u469/#SRC/#g' -e '1d' | md5sum)
b=$($UHDM_DUMP /tmp/intr11u467/probe/$f 2>/dev/null | sed -e 's#/tmp/intr11u467#WD#g' -e 's#/home/heyfey/git-repos/slang-uhdm/#SRC/#g' -e '1d' | md5sum)
[ "$a" = "$b" ] || echo $f
