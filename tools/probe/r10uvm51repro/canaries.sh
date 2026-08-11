#!/bin/bash
# r10uvm51repro/canaries.sh — spot-check the named canaries INDIVIDUALLY against
# the committed baseline, because an aggregate count can hide a swap (a test
# converting while another un-converts leaves every histogram unchanged).
#
#   usage: canaries.sh <new.csv> <baseline.csv>
#
# GUARD: a canary that appears in NEITHER csv prints ABSENT and is counted, so a
# typo'd name can never read as green.
set -u
NEW=${1:?new csv}
BASE=${2:?baseline csv}
NAMES="InterfaceModPort BlackParrotComplex InterfaceBinding InterfaceModExp
BindHierPath EnumConcat LowMemPkg paramod_genscope_child issue326_packed_mem
assignment-pattern hier_path MultirangesStartNotFromZero genscope_cells
genvar_loop_decl_3 ClassExtends FuncStruct FuncStructVal FuncIoTypespec
Scr1SvTests BasicOh Earlgrey_0_1 YosysOldOr YosysBigSimReed YosysOldOpen
ClassParamAsParam ClassTypeParam SVSwitch SimpleConstraint ApbSlave
SimpleUVM SeqDriver BuildUVMPkg Scoreboard"
bad=0; absent=0; ok=0
for n in $NAMES; do
  for m in default testflags; do
    b=$(awk -F, -v n="$n" -v m="$m" '$1==n && $2==m {print $3"/"$NF}' "$BASE")
    a=$(awk -F, -v n="$n" -v m="$m" '$1==n && $2==m {print $3"/"$NF}' "$NEW")
    if [ -z "$b" ] && [ -z "$a" ]; then continue; fi
    if [ -z "$b" ] || [ -z "$a" ]; then
      printf '  %-30s %-9s ABSENT base=[%s] new=[%s]\n' "$n" "$m" "$b" "$a"
      absent=$((absent+1)); continue
    fi
    if [ "$b" = "$a" ]; then
      printf '  %-30s %-9s OK      %s\n' "$n" "$m" "$a"; ok=$((ok+1))
    else
      printf '  %-30s %-9s CHANGED %s -> %s\n' "$n" "$m" "$b" "$a"; bad=$((bad+1))
    fi
  done
done
echo "---- canary rows: ok=$ok changed=$bad absent=$absent"
[ $((ok+bad+absent)) -gt 0 ] || { echo "REFUSING TO REPORT: matched no row"; exit 5; }
[ "$bad" -eq 0 ] || exit 1
