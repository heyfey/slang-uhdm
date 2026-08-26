#!/usr/bin/env bash
# r10uvm151 — run ct151cen over EVERY database of a sweep workdir (ours) and
# over its GOLDEN (read out of that test's own cmds.txt, so the pairing can
# never drift), writing one <tag>.g.cen / <tag>.o.cen pair per test.
# MEASUREMENT ONLY.  LHS is always golden; RHS is always ours.
#
#   CEN=<ct151cen> censweep151.sh <sweep-workdir> <out-dir>
#
# Ops traps paid for here (RESUME.md §9):
#   * the file list is read on fd 3 and every child gets </dev/null;
#   * PROCESSED is asserted against LISTED;
#   * every ct151cen invocation records its own rc (an rc=139 segfault must
#     not read as "no cells");
#   * scratch is keyed on the RELATIVE path, so two tests may share a leaf.
set -u
CEN=${CEN:?set CEN=<ct151cen binary>}
WD=${1:?usage: censweep151.sh <sweep-workdir> <out-dir>}
OUT=${2:?usage: censweep151.sh <sweep-workdir> <out-dir>}
mkdir -p "$OUT"
LIST=$OUT/.list
find "$WD" -name cmds.txt | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; nogold=0; noours=0; badrc=0
exec 3< "$LIST"
while IFS= read -r c <&3; do
  d=$(dirname "$c")
  rel=${d#"$WD"/}; tag=${rel//\//__}
  ours=$d/slang.uhdm
  gold=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' "$c" | head -1)
  [ -n "$gold" ] && gold=$gold/golden.uhdm
  if [ -f "$ours" ]; then
    "$CEN" "$ours" > "$OUT/$tag.o.cen" 2>"$OUT/$tag.o.err" </dev/null
    rc=$?; [ $rc -ne 0 ] && { echo "RC ours=$rc $rel"; badrc=$((badrc+1)); }
  else noours=$((noours+1)); fi
  if [ -n "$gold" ] && [ -f "$gold" ]; then
    "$CEN" "$gold" > "$OUT/$tag.g.cen" 2>"$OUT/$tag.g.err" </dev/null
    rc=$?; [ $rc -ne 0 ] && { echo "RC gold=$rc $rel"; badrc=$((badrc+1)); }
  else nogold=$((nogold+1)); fi
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc NO_OURS=$noours NO_GOLDEN=$nogold NONZERO_RC=$badrc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
