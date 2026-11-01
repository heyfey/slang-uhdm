#!/bin/bash
source /tmp/v11u458_env.sh >/dev/null
p=$1
a=$($UHDM_DUMP /tmp/v11u458sw1/probe/$p 2>/dev/null | sed 's#/tmp/v11u458sw1#W#g; s#/tmp/intr11u456#W#g; s#/tmp/wt_v11u458/#R/#g; s#/home/heyfey/git-repos/slang-uhdm/#R/#g' | md5sum | cut -c1-12)
b=$($UHDM_DUMP /tmp/intr11u456/probe/$p 2>/dev/null | sed 's#/tmp/v11u458sw1#W#g; s#/tmp/intr11u456#W#g; s#/tmp/wt_v11u458/#R/#g; s#/home/heyfey/git-repos/slang-uhdm/#R/#g' | md5sum | cut -c1-12)
[ "$a" = "$b" ] || echo "MOVER $p"
