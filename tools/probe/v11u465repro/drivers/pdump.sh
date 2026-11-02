#!/bin/bash
source /tmp/v11u465_env.sh >/dev/null || exit 9
f=$1
a=$("$UHDM_DUMP" /tmp/intr11u462/probe/$f 2>&1 | tail -n +2 | sed -e 's#/home/heyfey/git-repos/slang-uhdm#ROOT#g' -e 's#/tmp/wt_v11u465#ROOT#g' | md5sum)
b=$("$UHDM_DUMP" /tmp/v11u465sw1/probe/$f 2>&1 | tail -n +2 | sed -e 's#/home/heyfey/git-repos/slang-uhdm#ROOT#g' -e 's#/tmp/wt_v11u465#ROOT#g' | md5sum)
[ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
