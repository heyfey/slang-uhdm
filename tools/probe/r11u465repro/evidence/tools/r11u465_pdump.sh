#!/bin/bash
source /tmp/r11u465_env.sh; [ -x "$UHDM_DUMP" ] || exit 9
f=$1
a=$($UHDM_DUMP /tmp/intr11u462/probe/$f 2>&1 | tail -n +2 | sed -e 's#/home/heyfey/git-repos/slang-uhdm#ROOT#g' -e 's#/tmp/wt_r11u465#ROOT#g' | md5sum)
b=$($UHDM_DUMP /tmp/r11u465sw1/probe/$f 2>&1 | tail -n +2 | sed -e 's#/home/heyfey/git-repos/slang-uhdm#ROOT#g' -e 's#/tmp/wt_r11u465#ROOT#g' | md5sum)
[ "$a" = "$b" ] && echo "same $f" || echo "diff $f"
