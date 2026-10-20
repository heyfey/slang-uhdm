#!/bin/bash
# v11u419 away.sh (from r11u419) <row path without .sv>: law sv-tests database vs the master's control, distance to golden
# (uhdm-cmp lines, and the multiset distance of id- and path-normalized sorted dumps)
UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp; UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x $UHDM_CMP ] && [ -x $UHDM_DUMP ] || exit 1
t=$1; L=/tmp/v11u419_sw/svtests/work/$t; C=/tmp/intr11u417/svtests/work/$t
g=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' $L/cmds.txt); G=$g/golden.uhdm; [ -n "$g" ] || G=$L/slpp_all/surelog.uhdm
[ -f $C/slang.uhdm ] || { echo "$t NOCTL"; exit; }
nc=$(timeout 900 $UHDM_CMP $G $C/slang.uhdm 2>&1 | wc -l); nl=$(timeout 900 $UHDM_CMP $G $L/slang.uhdm 2>&1 | wc -l)
norm(){ timeout 1200 $UHDM_DUMP $1 2>/dev/null | sed 1d | sed "s/id:[0-9]*//g;s|/tmp/[^ ,]*/||g" | LC_ALL=C sort; }
gd=$(mktemp /tmp/v11u419_aw.XXXX); norm $G > $gd
dc=$(LC_ALL=C comm -3 $gd <(norm $C/slang.uhdm) | wc -l); dl=$(LC_ALL=C comm -3 $gd <(norm $L/slang.uhdm) | wc -l); rm -f $gd
v=same; [ $dl -lt $dc ] && v=toward; [ $dl -gt $dc ] && v=AWAY
echo "$t cmp $nc -> $nl multiset $dc -> $dl $v"
