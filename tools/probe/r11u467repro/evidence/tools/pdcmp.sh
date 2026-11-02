#!/bin/bash
# pdcmp.sh <relpath>: path-normalized uhdm-dump of the law sweep's probe db vs the control's
source /tmp/r11u467_env.sh; [ -x "$UHDM_DUMP" ] || exit 1
n(){ "$UHDM_DUMP" "$1" 2>&1 | sed -e 's#/tmp/wt_r11u467#/home/heyfey/git-repos/slang-uhdm#g' -e 's#/tmp/r11u467_sw#/tmp/intr11u465#g'; }
if cmp -s <(n /tmp/r11u467_sw/probe/$1) <(n /tmp/intr11u465/probe/$1); then echo "SAME $1"; else echo "DIFF $1"; fi
