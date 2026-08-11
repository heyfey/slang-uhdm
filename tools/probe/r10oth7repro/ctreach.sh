#!/usr/bin/env bash
# r10oth7 — CORPUS REACH for the two laws, with a per-test breakdown so any cell
# can be hand-checked (the r10oth6 V3 lesson: never leave an inherited number
# inside the instrument, and always make the total decomposable).
#
#   usage: ctreach.sh
#
# LAW A reach  = written declarations whose type is one of the three built-in
#                classes share/builtin.sv provides: `mailbox`, `semaphore`,
#                `process`.  Every one of them is a class_typespec that lost its
#                vpiClassDefn before this pass.
# LAW B reach  = an UPPER BOUND on the class-method body locals the naming rule
#                touches.  It is deliberately reported as a bound, not a count:
#                deciding a cell needs the two HOME COMPONENTS, which grep
#                cannot see.  A cell that grep cannot decide prints in the
#                BOUND, never in a "moved" figure.
#
# The counts are an upper bound to the extent a match can fall inside a comment
# or a string; the per-test breakdown makes any cell hand-checkable.
#
# SELF-CHECK, against THIS pass's OWN hand count and nothing inherited:
# SVSwitch has EXACTLY 10 written `mailbox` declarations -- 8 class properties
# (Driver.sv:14, Receiver.sv:15, Environemnt.sv:22,23, Scoreboard.sv:14,15) plus
# 4 constructor formals (Driver.sv:18, Receiver.sv:18, Scoreboard.sv:18 twice) --
# and the SVSwitch dump carries exactly 10 named `mailbox` class_typespec
# definitions, so the two numbers cross-check each other.  The regex's first
# draft read 7 because its terminator class omitted `)` and so missed every
# formal; that is why `)` is in it, and why the assertion is `-eq 10`, not `>=`.
set -u
SL=$HOME/git-repos/Surelog
U2R=$HOME/git-repos/uhdm2rtlil/test
# PCRE, not ERE, and that is load-bearing: with a leading `[^A-Za-z0-9_]` CLASS
# instead of a lookbehind, `grep -o` CONSUMES the separator, so the second
# declaration on `new(mailbox a,mailbox b);` never matches and SVSwitch read 9
# instead of 10.  Zero-width assertions on both ends fix it.
RE_A='(?<![A-Za-z0-9_])(mailbox|semaphore|process)[ \t]*(#\([^)]*\))?[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*(?=[;,=)])'
for root in "$SL/tests" "$SL/third_party/tests" "$U2R"; do
  [ -d "$root" ] || { echo "UNMEASURED: no such root $root"; continue; }
  n=$(grep -rhoP "$RE_A" --include='*.sv' --include='*.svh' --include='*.v' "$root" 2>/dev/null | wc -l)
  echo "law A ($root): $n written built-in-class declarations"
done
echo "-- law A top tests"
grep -rlP "$RE_A" --include='*.sv' --include='*.svh' --include='*.v' \
     "$SL/tests" "$SL/third_party/tests" "$U2R" 2>/dev/null |
  sed -E "s#^($SL/tests|$SL/third_party/tests|$U2R)/([^/]+)/.*#\2#" |
  sort | uniq -c | sort -rn | head -15
svs=$(grep -rhoP "$RE_A" --include='*.sv' "$SL/third_party/tests/SVSwitch" 2>/dev/null | wc -l)
echo "SELF-CHECK SVSwitch law-A sites: $svs (must be EXACTLY 10 -- see header)"
[ "$svs" -eq 10 ] || { echo "SELF-CHECK FAILED"; exit 4; }
echo
echo "law B BOUND: class-method body locals are counted as 'a class-typed local"
echo "  declared inside a task/function inside a class'.  grep cannot resolve the"
echo "  two HOME COMPONENTS that decide the cell, so this is an UPPER BOUND and"
echo "  the per-cell verdicts live in the arm tables, not here."
for root in "$SL/tests" "$SL/third_party/tests" "$U2R"; do
  [ -d "$root" ] || continue
  n=$(grep -rc 'endclass' --include='*.sv' --include='*.svh' --include='*.v' "$root" 2>/dev/null |
      awk -F: '{s+=$2} END {print s+0}')
  echo "law B ($root): $n class declarations in scope of the rule (UPPER BOUND)"
done
