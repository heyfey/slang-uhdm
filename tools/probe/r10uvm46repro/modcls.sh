#!/bin/bash
# r10uvm46 (cloned from pass 45) — THE MODULE-TABLE vs $unit-CLASS-TABLE comparison, the pass-45
# ranked-#1 measurement, run off an ls.sh dump pair.
#
# Pass 44 reported that on SimpleUVM golden's TOP-MODULE vpiTypedef table is
# byte-identical, as an ordered (kind,name) sequence, to golden's $unit CLASS
# table, and that OUR class table already reproduces golden's.  That claim is a
# THREE-WAY sequence comparison and neither ls.sh projection can show it: the
# scope-level dump puts 123 entries on one line, and the -e dump prefixes an
# INDEX so one insertion shifts every later line.  This driver emits the four
# bare ordered sequences and diffs them pairwise, and it names the enclosing
# $unit class rather than assuming `work@env`.
#
#   usage: modcls.sh <test> <tag> [classscope]
# reads  /tmp/r10uvm46_ls_{g,<tag>}_<test>.txt   (produced by ls.sh)
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=${1:?}
TAG=${2:?}
GF=/tmp/r10uvm46_ls_g_$T.txt
OF=/tmp/r10uvm46_ls_${TAG}_$T.txt
for f in "$GF" "$OF"; do
  [ -s "$f" ] || { echo "missing $f — run ls.sh first"; exit 1; }
done
# The module DEF view's scope name is EMPTY, and a design has one such line per
# module (SimpleUVM has three: the top's 123-entry one plus `dut` and an
# anonymous n=0).  `head -1` therefore picked an n=0 line and every comparison
# printed a number computed from a ONE-ENTRY sequence — so select the def line
# by MEASURED SIZE, which is the same construction CLS uses below, and print the
# full n= so the choice is visible.
MODDEF="module_inst ''/def"
MODTOP=$(grep -oE "module_inst '[^']+'/top" "$GF" | head -1)
if [ -n "${3:-}" ]; then
  CLS=$3
else
  # The $unit class carrying the biggest table (Surelog hangs the whole $unit
  # type table off the FIRST $unit class); pick it by measured size, do not
  # assume a name.
  CLS=$(grep -E "^class_defn 'work@" "$GF" \
        | sed -E "s/^(class_defn '[^']+') n=([0-9]+).*/\2 \1/" \
        | sort -rn | head -1 | cut -d' ' -f2-)
fi
echo "scopes: MODDEF=[$MODDEF] MODTOP=[$MODTOP] CLS=[$CLS]"
# A DRIVER THAT CANNOT FIND ITS HELPER REPORTS PERFECTION — pass 44's cp.sh
# printed `golden=0 ours=0 diff=0` for every test because its probe path was
# wrong, and the FIRST run of this driver printed `0 diff lines` on all five
# comparisons because seq.sh was not executable.  Refuse to print a number
# unless the helper runs AND the three golden scopes were actually found.
[ -x "$HERE"/seq.sh ] || { echo "FATAL: $HERE/seq.sh not executable"; exit 3; }
[ -n "$MODTOP" ] || { echo "FATAL: no /top module scope in $GF"; exit 3; }
[ -n "$CLS" ] || { echo "FATAL: no work@ class scope in $GF"; exit 3; }
"$HERE"/seq.sh "$GF" "$MODDEF" > /tmp/r10uvm46_mc_gmd_$T.txt
"$HERE"/seq.sh "$GF" "$MODTOP"  > /tmp/r10uvm46_mc_gmt_$T.txt
"$HERE"/seq.sh "$GF" "$CLS"     > /tmp/r10uvm46_mc_gcl_$T.txt
"$HERE"/seq.sh "$OF" "$MODDEF" > /tmp/r10uvm46_mc_omd_$T.txt
"$HERE"/seq.sh "$OF" "$MODTOP"  > /tmp/r10uvm46_mc_omt_$T.txt
"$HERE"/seq.sh "$OF" "$CLS"     > /tmp/r10uvm46_mc_ocl_$T.txt
for k in gmd gmt gcl omd omt ocl; do
  printf '  %s n=%s\n' "$k" "$(wc -l < /tmp/r10uvm46_mc_${k}_$T.txt)"
done
for k in gmd gmt gcl; do
  [ -s /tmp/r10uvm46_mc_${k}_$T.txt ] || { echo "FATAL: golden sequence $k is EMPTY"; exit 3; }
done
d() { echo "-- $1 vs $2: $(diff /tmp/r10uvm46_mc_$1_$T.txt /tmp/r10uvm46_mc_$2_$T.txt | grep -c '^[<>]') diff lines"; }
d gmd gmt      # golden module def vs golden module top
d gmd gcl      # golden module def vs golden $unit class   <- the claim
d gcl ocl      # golden class    vs ours class             <- the claim
d gmd omd      # golden module def vs ours module def
d omd omt      # ours module def vs ours module top
echo "=== golden-module-def MINUS ours-module-def (entries we never publish)"
comm -23 <(sort /tmp/r10uvm46_mc_gmd_$T.txt) <(sort /tmp/r10uvm46_mc_omd_$T.txt)
echo "=== ours-module-def MINUS golden-module-def (entries we publish and golden does not)"
comm -13 <(sort /tmp/r10uvm46_mc_gmd_$T.txt) <(sort /tmp/r10uvm46_mc_omd_$T.txt)
