#!/bin/bash
# r11u206: each switch alone.  For every case dir under the roots (fence fail-closed), the law binary runs once plain
# (with R11U206_TRACE) and once per switch with only that switch set; prints, per switch, the cases whose
# database moved, and flags a mover whose plain run did not trace the switch's law (a switch reaching outside its law).
# usage: switches.sh <law bin name in $B> <root>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LAW=$1; shift; O=/tmp/r11u206_switches; mkdir -p $O
SW="R11U206_TPCASTDEF_OFF:tpCastUseBindsDefDefault206 R11U206_TPARRELEM_OFF:tpArrayElemBindsDefDefault206 R11U206_UTIFCPRG_OFF:unitClassTdEndAtInitIfcPrg206 R11U206_CLSCOPETDRET_OFF:classScopeTdRetBuildsOwner206 R11U206_GENCLSVAR_OFF:genScopeClassVarListed206 R11U206_GENCLSSPAN_OFF:genScopeClassVarSpecAtName206"
fre=$(echo $FENCED | sed 's/ /|/g')
one() { d=$1; k=$(echo $d | md5sum | cut -c1-12); w=$O/$k; mkdir -p $w/tr; rm -f $w/tr/* $w/*.uhdm
  ( cd $d && R11U206_TRACE=$w/tr $B/$LAW dut.sv --single-unit --nobuiltin -o $w/plain.uhdm > /dev/null 2>&1 )
  fired=$(cat $w/tr/* 2>/dev/null | grep -v '^OUT ' | awk '{print $1}' | sort -u | tr '\n' ' ')
  for sw in $SW; do v=${sw%%:*}; l=${sw#*:}
    ( cd $d && env $v=1 $B/$LAW dut.sv --single-unit --nobuiltin -o $w/$v.uhdm > /dev/null 2>&1 )
    if ! cmp -s $w/plain.uhdm $w/$v.uhdm; then
      if echo " $fired " | grep -q " $l "; then echo "$v MOVES $d"; else echo "$v MOVES_UNTRACED $d"; fi; fi
    rm -f $w/$v.uhdm; done; }
export -f one; export B LAW O SW
for r in "$@"; do find -L $r -name dut.sv -printf '%h\n'; done | grep -Evw "$fre" | sort -u | xargs -P3 -I{} bash -c 'one {}' | sort > $O/last.txt
awk '{print $1, $2}' $O/last.txt | sort | uniq -c; echo "UNTRACED $(grep -c MOVES_UNTRACED $O/last.txt)"
