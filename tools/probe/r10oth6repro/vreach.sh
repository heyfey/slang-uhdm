#!/usr/bin/env bash
# vreach.sh -- count WRITTEN `virtual <iface>` declarations across BOTH corpora,
# split by spelling, and print UNMEASURED for a corpus root that is not there.
#
#   usage: ./vreach.sh
#
# A BROKEN COUNTER REPORTS A CLOSED HEAD.  The master's first count of this
# shape printed ZERO because it piped per-file `grep -c` through `bc`; the form
# that works is `grep -rhoE ... | wc -l`, which is what this uses, and the
# per-test breakdown at the end is the hand-checkable control.
#
# SELF-CHECK, CORRECTED BY THE r10oth6 VERIFIER.  This line used to read
# "SVSwitch must read 4 -- Driver.sv, Receiver.sv and Environemnt.sv x2 -- and
# Scoreboard 0".  THAT IS THE MASTER'S INHERITED NUMBER AND IT IS WRONG FOR THIS
# SCRIPT: 4 counts class PROPERTIES only, while this script's own definition
# (stated below) also counts formals, method locals and module variables.  The
# script prints 10 for SVSwitch, and 10 is correct -- 5 properties + 5
# constructor formals, hand-listed in README section 6.  A driver whose
# self-check contradicts its own output is worse than one with no self-check.
# CORRECT CONTROL: SVSwitch must read 10, and Scoreboard must read 0.
set -u
SL=${SURELOG_ROOT:-$HOME/git-repos/Surelog}
U2R=${UHDM2RTLIL_TESTS:-$HOME/git-repos/uhdm2rtlil/test}
# `virtual` followed by an optional `interface` keyword and a type name, but
# NOT `virtual class` / `virtual function` / `virtual task` / `virtual local`.
RE='\bvirtual[ \t]+(interface[ \t]+)?[A-Za-z_][A-Za-z_0-9]*[ \t]*(\.[A-Za-z_][A-Za-z_0-9]*)?[ \t]+[A-Za-z_]'
KW='virtual[ \t]+(class|function|task|protected|local|static|pure)\b'
for root in "$SL/tests" "$SL/third_party/tests" "$U2R"; do
  if [ ! -d "$root" ]; then echo "UNMEASURED(no such corpus root: $root)"; continue; fi
  all=$(grep -rhoE "$RE" --include='*.sv' --include='*.svh' --include='*.v' "$root" 2>/dev/null | grep -vE "$KW" | wc -l)
  mp=$(grep -rhoE "$RE" --include='*.sv' --include='*.svh' --include='*.v' "$root" 2>/dev/null | grep -vE "$KW" | grep -cE '\.' )
  echo "$root: virtual-interface declarations=$all  of which MODPORT-selected=$mp"
done
echo "--- per-test (surelog corpus, top 15) ---"
for d in "$SL"/tests/*/ "$SL"/third_party/tests/*/; do
  [ -d "$d" ] || continue
  n=$(grep -rhoE "$RE" --include='*.sv' --include='*.svh' --include='*.v' "$d" 2>/dev/null | grep -vE "$KW" | wc -l)
  [ "$n" -gt 0 ] && echo "$n $(basename "$d")"
done | sort -rn | head -15
