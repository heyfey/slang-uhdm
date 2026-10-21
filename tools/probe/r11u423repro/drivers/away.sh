#!/bin/bash
# r11u423 away census: for each sv-tests row, multiset distance (comm -3 over sorted, header-stripped dumps)
# golden vs control and golden vs law, plus uhdm-cmp line counts.  usage: away.sh <law workroot> <control workroot> <rows file> <out>
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
[ -x "$DUMP" ] && [ -x "$CMP" ] || exit 1
L=$1; C=$2; : > $4
while read r; do
  g=$(grep -o 'golden cache hit [^)]*' $L/$r/cmds.txt | awk '{print $4}')/golden.uhdm
  [ -f "$g" ] || g=$L/$r/slpp_all/surelog.uhdm
  T=/tmp/r11u423_away; mkdir -p $T
  $DUMP $g 2>/dev/null | sed 1d | sort > $T/g.s
  $DUMP $C/$r/slang.uhdm 2>/dev/null | sed 1d | sort > $T/c.s
  $DUMP $L/$r/slang.uhdm 2>/dev/null | sed 1d | sort > $T/l.s
  dc=$(comm -3 $T/g.s $T/c.s | wc -l); dl=$(comm -3 $T/g.s $T/l.s | wc -l)
  cc=$($CMP $g $C/$r/slang.uhdm 2>&1 | wc -l); cl=$($CMP $g $L/$r/slang.uhdm 2>&1 | wc -l)
  echo "$r control=$dc law=$dl cmp_control=$cc cmp_law=$cl $([ $dl -lt $dc ] && echo toward || ([ $dl -eq $dc ] && echo same || echo AWAY))" >> $4
done < $3
