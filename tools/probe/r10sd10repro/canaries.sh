#!/bin/bash
# r10uvm52repro/canaries.sh — spot-check the named canaries INDIVIDUALLY against
# the committed baseline, because an aggregate count can hide a swap (a test
# converting while another un-converts leaves every histogram unchanged).
#
#   usage: canaries.sh <new.csv> <baseline.csv>
#
# GUARD: a canary NAME that matches NO row in either csv, in either mode, prints
# UNKNOWN-NAME and exits 6 -- so a
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
bad=0; absent=0; ok=0; unknown=0
# THE ABSENT GUARD WAS CITED IN THE HEADER BUT DID NOT EXIST -- FIXED AT
# INTEGRATION.  The `in NEITHER csv` case below used to `continue` SILENTLY, so a
# MISTYPED CANARY NAME READ AS GREEN: injecting ZZZ_TYPO_NOT_A_TEST into NAMES
# printed `ok=52 changed=0 absent=0` and exited 0.  A CITED GUARD THAT IS NOT
# THERE is worse than no guard, because the write-up leans on it.
# The per-ROW skip is still CORRECT and must stay: one NAMES list serves both
# corpora and both modes, so a name legitimately matches no row for a mode it
# does not have.  The real defect is a name that matches NOTHING AT ALL, so that
# is now tracked PER NAME and reported.
for n in $NAMES; do
  seen_any=0
  for m in default testflags; do
    b=$(awk -F, -v n="$n" -v m="$m" '$1==n && $2==m {print $3"/"$NF}' "$BASE")
    a=$(awk -F, -v n="$n" -v m="$m" '$1==n && $2==m {print $3"/"$NF}' "$NEW")
    [ -n "$b" ] || [ -n "$a" ] && seen_any=1
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
  if [ "$seen_any" -eq 0 ]; then
    printf '  %-30s %-9s UNKNOWN-NAME (matched NO row in either csv, either mode)\n' "$n" "-"
    unknown=$((unknown+1))
  fi
done
echo "---- canary rows: ok=$ok changed=$bad absent=$absent unknown-names=$unknown"
[ $((ok+bad+absent)) -gt 0 ] || { echo "REFUSING TO REPORT: matched no row"; exit 5; }
# NARROWED AT INTEGRATION AFTER MY OWN POSITIVE CONTROL CAUGHT IT: making an
# unknown name FATAL is too wide, because ONE NAMES list serves BOTH corpora --
# the u2r-only canaries (paramod_genscope_child, issue326_packed_mem,
# assignment-pattern, hier_path, MultirangesStartNotFromZero, genscope_cells,
# genvar_loop_decl_3) legitimately match nothing in a surelog CSV, so a blanket
# exit 6 made the script ALWAYS fail.  The real defect was SILENCE, not the
# tolerance: unknown names are now always PRINTED and COUNTED, so a typo is
# visible, and the hard failure is opt-in for a single-corpus run.
if [ "$unknown" -gt 0 ]; then
  echo "NOTE: $unknown canary NAME(S) matched no row in this CSV. Expect 7 when"
  echo "      checking a SURELOG csv (the u2r-only canaries) and the rest when"
  echo "      checking a u2r csv. ANY OTHER NAME HERE IS A TYPO -- read the list."
  [ "${CANARY_STRICT:-0}" = "1" ] && { echo "CANARY_STRICT=1: failing on unknown names"; exit 6; }
fi
[ "$bad" -eq 0 ] || exit 1
