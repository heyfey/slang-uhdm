#!/bin/bash
# away.sh <row> <ctlwork> <newwork>: uhdm-cmp line count and exact multiset distance (comm -3 over sorted,
# id- and path-normalized dumps) to golden, control database vs new database
source /tmp/v11u418_env.sh
t=$1; C=$2/$t; L=$3/$t
g=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' $L/cmds.txt); G=$g/golden.uhdm; [ -n "$g" ] || G=$L/slpp_all/surelog.uhdm
[ -f $C/slang.uhdm ] && [ -f $L/slang.uhdm ] && [ -f $G ] || { echo "$t MISSING"; exit; }
nc=$(timeout 900 $UHDM_CMP $G $C/slang.uhdm 2>&1 | wc -l); nl=$(timeout 900 $UHDM_CMP $G $L/slang.uhdm 2>&1 | wc -l)
norm(){ timeout 900 $UHDM_DUMP $1 2>/dev/null | sed 1d | sed 's/id:[0-9]*//g;s|/tmp/[^ ,]*/||g' | LC_ALL=C sort; }
gd=$(mktemp /tmp/v11u418_awayg.XXXX); norm $G > $gd
dc=$(LC_ALL=C comm -3 $gd <(norm $C/slang.uhdm) | wc -l); dl=$(LC_ALL=C comm -3 $gd <(norm $L/slang.uhdm) | wc -l); rm -f $gd
v=same; [ $dl -lt $dc ] && v=toward; [ $dl -gt $dc ] && v=AWAY
echo "$t cmp $nc -> $nl multiset $dc -> $dl $v"
