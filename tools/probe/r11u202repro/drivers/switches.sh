#!/bin/bash
# r11u202: each switch alone.  For every case dir under the roots (fence fail-closed), the law binary runs once plain
# (with R11U200_TRACE / R11U202_TRACE) and once per switch with only that switch set; prints, per switch, the cases whose
# database moved, and flags a mover whose plain run did not trace the switch's law (a switch reaching outside its law).
# usage: switches.sh <law bin name in $B> <root>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LAW=$1; shift; O=/tmp/r11u202_switches; mkdir -p $O
SW="R11U200_SIGNSPAN_OFF:tfSigningSpanFollowsCompilePath200 R11U200_GENINIT_OFF:defGenInitRhsKeepsParent200 R11U200_IFARRNAME_OFF:ifaceArrPortElemViewNamedByArray200 R11U200_IMPLEND_OFF:implicitTsEndCrossesLineBreak200 R11U200_PORTPACKED_OFF:defPortPackedTsKeepsWholeSpan200 R11U200_UNITINIT_OFF:unitBoundFoldAtLeftOperand200 R11U200_CLASSCRASH_OFF:modGenericClassListedAtDefault200 R11U200_CLASSTDRET_OFF:classTdRetSharesTypedefTs200 R11U200_POSREFMOD_OFF:posOpConnKeepsRefModule200 R11U200_GENBITS_OFF:genBlockBitsKeepsSelect200 R11U202_UNITCLSTD_OFF:unitClassTdSpecAtName202 R11U202_CLSTDINITEND_OFF:unitClassTdEndAtInit202 R11U202_SPECARGS_OFF:classSpecExprArgUnlocated202 R11U202_CLSPARAMSIGN_OFF:classValueParamIntSigned202 R11U202_MODPKGSPEC_OFF:modPkgGenericSpecNamedBare202 R11U202_VALSPECSPAN_OFF:modSpecValueArgSpanAtName202 R11U202_GENINITBIND_OFF:genVarInitOuterRefUnbound202 R11U202_GENINITBS_OFF:defGenInitBitSelAtIndex202"
fre=$(echo $FENCED | sed 's/ /|/g')
one() { d=$1; k=$(echo $d | md5sum | cut -c1-12); w=$O/$k; mkdir -p $w/tr; rm -f $w/tr/* $w/*.uhdm
  ( cd $d && R11U200_TRACE=$w/tr R11U202_TRACE=$w/tr $B/$LAW dut.sv --single-unit --nobuiltin -o $w/plain.uhdm > /dev/null 2>&1 )
  fired=$(cat $w/tr/* 2>/dev/null | grep -v '^OUT ' | awk '{print $1}' | sort -u | tr '\n' ' ')
  for sw in $SW; do v=${sw%%:*}; l=${sw#*:}
    ( cd $d && env $v=1 $B/$LAW dut.sv --single-unit --nobuiltin -o $w/$v.uhdm > /dev/null 2>&1 )
    if ! cmp -s $w/plain.uhdm $w/$v.uhdm; then
      if echo " $fired " | grep -q " $l "; then echo "$v MOVES $d"; else echo "$v MOVES_UNTRACED $d"; fi; fi
    rm -f $w/$v.uhdm; done; }
export -f one; export B LAW O SW
for r in "$@"; do find -L $r -name dut.sv -printf '%h\n'; done | grep -Evw "$fre" | sort -u | xargs -P3 -I{} bash -c 'one {}' | sort > $O/last.txt
awk '{print $1, $2}' $O/last.txt | sort | uniq -c; echo "UNTRACED $(grep -c MOVES_UNTRACED $O/last.txt)"
