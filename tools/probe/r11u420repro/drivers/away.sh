#!/bin/bash
# away.sh <relative test path without .sv>: the multiset distance (comm -3 over
# sorted, id- and path-stripped uhdm-dump lines) of golden against the master's
# control database (/tmp/intr11u418) and against this pass's law database
# (/tmp/r11u420_sw); prints toward / same / AWAY.
source /tmp/r11u420_env.sh
t=$1
L=/tmp/r11u420_sw/svtests/work/$t; C=/tmp/intr11u418/svtests/work/$t
g=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' $L/cmds.txt); G=$g/golden.uhdm; [ -n "$g" ] || G=$L/slpp_all/surelog.uhdm
[ -f $C/slang.uhdm ] || { echo "$t NOCTL"; exit; }
[ -f $L/slang.uhdm ] || { echo "$t NOLAW"; exit; }
norm(){ $UHDM_DUMP $1 2>/dev/null | sed 1d | sed "s/id:[0-9]*//g;s|/tmp/[^ ,]*/||g" | LC_ALL=C sort; }
gd=$(mktemp /tmp/r11u420_aw.XXXXXX); norm $G > $gd
dc=$(LC_ALL=C comm -3 $gd <(norm $C/slang.uhdm) | wc -l); dl=$(LC_ALL=C comm -3 $gd <(norm $L/slang.uhdm) | wc -l); rm -f $gd
nc=$(timeout 600 $UHDM_CMP $G $C/slang.uhdm 2>&1 | wc -l); nl=$(timeout 600 $UHDM_CMP $G $L/slang.uhdm 2>&1 | wc -l)
v=same; [ $dl -lt $dc ] && v=toward; [ $dl -gt $dc ] && v=AWAY
echo "$t cmp $nc -> $nl multiset $dc -> $dl $v"
