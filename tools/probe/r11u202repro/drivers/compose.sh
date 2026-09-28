#!/bin/bash
# r11u202: the composition of the r11u200 class-listing law with pass 196's (the reconciled switch family).
# Four configurations per case: neither (pris.bin, R11U196_MODGENERIC_OFF+MODGENHANDLE_OFF+MODCLSLINK_OFF),
# 196 alone (pris.bin), 200 alone (the law binary with the three 196 switches off), both (the law binary).
# usage: compose.sh <law binary name in $B> <case dir>...   -> <case> neither 196 200 both, plus md5 equalities
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LAW=$1; shift
OFF196="R11U196_MODGENERIC_OFF=1 R11U196_MODGENHANDLE_OFF=1 R11U196_MODCLSLINK_OFF=1"
V() { awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($3=="STRICT_EQUAL") print "EQUAL"; else if ($3=="NOT_EQUAL") print "NOT_EQUAL"; else print $3":"$4 }'; }
for c in "$@"; do c=$(cd $c && pwd); r=$(echo $c | sed 's#.*/tools/probe/##'); line="$r"; declare -A md
  for cfg in neither:pris.bin:"$OFF196" c196:pris.bin: c200:$LAW:"$OFF196" both:$LAW:; do
    n=${cfg%%:*}; rest=${cfg#*:}; b=${rest%%:*}; e=${rest#*:}; o=/tmp/r11u202_compose/$n/$r
    v=$(env $e SLANG_UHDM=$B/$b bash $HERE/case.sh $c $o 2>/dev/null | V)
    k=$(grep -o 'objects_differing=[0-9]*' $o/strict.txt 2>/dev/null | cut -d= -f2); [ -n "$k" ] && v="$v($k)"
    md[$n]=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-8); line="$line	$n=$v"; done
  el=$(bash -c "(cd $c && env $OFF196 $B/$LAW dut.sv --single-unit --nobuiltin --elabuhdm -o /tmp/r11u202_compose/el.uhdm >/dev/null 2>&1); echo \$?")
  el2=$(bash -c "(cd $c && $B/$LAW dut.sv --single-unit --nobuiltin --elabuhdm -o /tmp/r11u202_compose/el.uhdm >/dev/null 2>&1); echo \$?")
  echo "$line	both==196:$([ "${md[both]}" = "${md[c196]}" ] && echo y || echo n)	elab_rc(200alone,both)=$el,$el2"; done
