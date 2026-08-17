#!/bin/bash
# r10ladder1/regate.sh — RE-VERIFY gates 3 and 4 from their SAVED EVIDENCE,
# with no workdir at all.
#
# The control workdirs this campaign runs on are rotated and pruned constantly
# (this pass lost TWO of them mid-run).  A gate whose only evidence is a table
# printed into a transcript is a gate that cannot be checked again, so
# `rowsanity.sh` and `detcheck.sh` both leave their raw pairs on disk and this
# script re-derives the verdict from those pairs alone:
#
#   gate 3 — <out>/head1_<row>.cmp  vs  .lad   must be BYTE IDENTICAL
#            (uhdm-cmp's own stderr vs ctladder --head1's)
#   gate 4 — <out>/det_<row>.a      vs  .b     must be IDENTICAL
#            (two independent ladder runs, wall-clock stripped)
#
#   usage: regate.sh <gate3-outdir> <gate4-outdir>
#
# GUARD: zero pairs found is a FAILURE, not a pass — an empty re-verification
# is precisely the result that reads as perfection.
set -u
G3=${1:?gate3 outdir}; G4=${2:?gate4 outdir}
n3=0; b3=0; n4=0; b4=0
echo "-- gate 3 re-verification (head1 pairs in $G3)"
for f in "$G3"/head1_*.cmp; do
  [ -f "$f" ] || continue
  l=${f%.cmp}.lad
  [ -f "$l" ] || { echo "  MISSING $l"; b3=$((b3+1)); continue; }
  s=$(wc -c < "$f")
  if [ "$s" -eq 0 ]; then echo "  EMPTY-HEAD $(basename "$f")"; b3=$((b3+1));
  elif cmp -s "$f" "$l"; then printf "  %-40s %12s bytes IDENTICAL\n" "$(basename "${f%.cmp}")" "$s"; n3=$((n3+1));
  else echo "  MISMATCH $(basename "$f")"; b3=$((b3+1)); fi
done
echo "-- gate 4 re-verification (ladder pairs in $G4)"
for f in "$G4"/det_*.a; do
  [ -f "$f" ] || continue
  b=${f%.a}.b
  [ -f "$b" ] || { echo "  MISSING $b"; b4=$((b4+1)); continue; }
  r=$(grep -c '^RUNG' "$f")
  if [ "$r" -eq 0 ]; then echo "  EMPTY-LADDER $(basename "$f")"; b4=$((b4+1));
  elif diff -q "$f" "$b" >/dev/null; then printf "  %-40s %6s rungs IDENTICAL\n" "$(basename "${f%.a}")" "$r"; n4=$((n4+1));
  else echo "  DIFFERS $(basename "$f")"; b4=$((b4+1)); fi
done
echo "[S] REGATE gate3 ok=$n3 bad=$b3   gate4 ok=$n4 bad=$b4"
[ "$n3" -gt 0 ] && [ "$n4" -gt 0 ] && [ "$b3" -eq 0 ] && [ "$b4" -eq 0 ]
