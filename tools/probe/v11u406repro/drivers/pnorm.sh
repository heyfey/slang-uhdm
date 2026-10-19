#!/bin/bash
source /tmp/v11u406_env.sh
f=$1
a=$($UHDM_DUMP /tmp/v11u406law/probe/$f 2>/dev/null | sed 1d | sed 's#/tmp/wt_v11u406/#/home/heyfey/git-repos/slang-uhdm/#g' | md5sum)
b=$($UHDM_DUMP /tmp/intr11u404/probe/$f 2>/dev/null | sed 1d | md5sum)
[ "$a" = "$b" ] && echo "same $f" || echo "DIFF $f"
