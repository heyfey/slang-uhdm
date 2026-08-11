#!/usr/bin/env bash
# r10oth8 — CORPUS REACH for § arrayVarSignedWritten8, RE-MEASURED FROM SCRATCH.
#
#   usage: ct8reach.sh
#
# THE NUMBER THIS REPLACES.  The r10oth8 brief carries an inherited figure of
# "479 signed-element dynamic/queue/assoc declarations across both corpora (155
# queue, 304 dynamic, 20 assoc)" and explicitly flags it UNVERIFIED, measured for
# a different residue.  Nothing below is inherited from it; every number here is
# produced by this script.  The brief's decomposition is also not reproducible
# from any regex here, so it is not repeated anywhere in this pass's write-up.
#
# WHAT GREP CAN AND CANNOT DECIDE, stated up front because the law turns on
# exactly the part grep cannot see:
#   * DECIDABLE  — an element type written as an INTEGER KEYWORD.  `byte x[]` is
#     visibly `byte`, and byte/shortint/int/longint/integer are SIGNED BY
#     DEFAULT (LRM 6.11) with no `signed` token anywhere.  A census grepping for
#     the literal keyword `signed` returns ~zero and proves nothing; that
#     mistake is recorded in the brief and is not repeated here.
#   * UNDECIDABLE — an element type written as a NAME (`uvm_reg_addr_t x[]`).
#     Whether it resolves to a signed type is a compile-time fact.  These are
#     reported SEPARATELY as the TIGHTENING-EXPOSED population, never folded
#     into the ADD population, and never presented as a count of movers.
# Both figures are UPPER BOUNDS: a match can fall inside a comment, a string or
# a subroutine formal.  The per-test breakdown makes any cell hand-checkable,
# which is the r10oth6 V3 lesson (a total must be decomposable).
#
# SELF-CHECK, from THIS pass's own hand count: SVSwitch has EXACTLY ONE written
# integer-keyword unsized-array declaration -- `rand byte data[];` at
# Packet.sv:23, which is the target head -- and the assertion below is `-eq 1`,
# not `>=`.  If the regex ever matches more or fewer there, the script fails
# loudly instead of publishing a number nobody checked.
set -u
SL=$HOME/git-repos/Surelog
U2R=$HOME/git-repos/uhdm2rtlil/test
INC=(--include=*.sv --include=*.svh --include=*.v --include=*.vh)

# ADD population: a written SIGNED integer keyword element, then a declarator
# name, then an OPENING bracket.  `unsigned` is excluded by the negative
# lookahead; `time` and `bit`/`logic` are simply not in the alternation because
# they are unsigned.  Zero-width assertions on BOTH ends -- with a character
# class instead, `grep -o` CONSUMES the separator and a second declaration on
# the same line is missed (an r10oth7 regex defect, fixed there and not
# re-introduced here).
RE_ADD='(?<![A-Za-z0-9_$.])(byte|shortint|int|longint|integer)(?![A-Za-z0-9_$])(?![ \t]+unsigned)([ \t]+signed)?[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*\['
# TIGHTENING-EXPOSED population: element written as a type NAME (optionally
# package-qualified) followed by a declarator and an UNSIZED/SIZED dim.  This is
# where the two module-scope sites used to over-fire.  Deliberately loose, and
# deliberately labelled UNDECIDABLE.
RE_TD='(?<![A-Za-z0-9_$.])[A-Za-z_][A-Za-z0-9_]*(::[A-Za-z_][A-Za-z0-9_]*)?[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*\[[ \t]*(\]|\$)'

count() { grep -rhoP "$1" "${INC[@]}" "$2" 2>/dev/null | wc -l; }

tot_add=0; tot_td=0
for root in "$SL/tests" "$SL/third_party/tests" "$U2R"; do
  if [ ! -d "$root" ]; then echo "UNMEASURED: no such root $root"; continue; fi
  a=$(count "$RE_ADD" "$root"); t=$(count "$RE_TD" "$root")
  tot_add=$((tot_add+a)); tot_td=$((tot_td+t))
  printf 'ADD-population   %-52s %6d  (DECIDABLE: written signed integer keyword)\n' "$root" "$a"
  printf 'TD-population    %-52s %6d  (UNDECIDABLE by grep: element is a NAME)\n'   "$root" "$t"
done
echo "TOTAL ADD-population (both corpora): $tot_add"
echo "TOTAL TD-population  (both corpora): $tot_td"
echo
echo "-- ADD-population, top tests (per-test breakdown, hand-checkable)"
grep -rlP "$RE_ADD" "${INC[@]}" "$SL/tests" "$SL/third_party/tests" "$U2R" 2>/dev/null |
  sed -E "s#^($SL/tests|$SL/third_party/tests|$U2R)/([^/]+)/.*#\2#" |
  sort | uniq -c | sort -rn | head -12
echo
echo "-- the UVM LIBRARY ITSELF, which is NOT under either tests root: the four"
echo "   UVM tests' .sl files point at \$SL/third_party/UVM/..., so its"
echo "   declarations are in NEITHER total above.  Counted separately here."
for uvmroot in "$SL/third_party/UVM"/*; do
  [ -d "$uvmroot" ] || continue
  ua=$(count "$RE_ADD" "$uvmroot"); ut=$(count "$RE_TD" "$uvmroot")
  printf '   %-46s ADD=%-5d TD=%-5d\n' "$(basename "$uvmroot")" "$ua" "$ut"
done
svs=$(grep -rhoP "$RE_ADD" "${INC[@]}" "$SL/third_party/tests/SVSwitch" 2>/dev/null | wc -l)
echo "SELF-CHECK SVSwitch ADD-population: $svs (must be EXACTLY 1 -- Packet.sv:23)"
[ "$svs" -eq 1 ] || { echo "SELF-CHECK FAILED -- the regex, not the corpus, changed"; exit 4; }
echo "SELF-CHECK PASSED"
