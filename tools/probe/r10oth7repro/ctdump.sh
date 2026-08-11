#!/usr/bin/env bash
# r10oth7 — dump/cmp one (golden, ours) pair and report BOTH distance numbers.
#
#   usage: ctdump.sh <golden.uhdm> <ours.uhdm> <tag>
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours, matching
# `uhdm-cmp <golden.uhdm> <ours.uhdm>`.
#
# OPS TRAPS THIS SCRIPT ENCODES rather than documents:
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs, so both
#     dumps are `sed 1d`'d before anything counts them.  Convention used
#     everywhere in this pass: content = lines of `diff -u` starting with -/+
#     MINUS diff's own `---`/`+++` header (which `sed 1d` does NOT remove; the
#     r10oth6 verifier's V2 defect was exactly conflating the two traps).
#   * uhdm-cmp EXITS 0 WHEN AN INPUT FILE IS MISSING -> both inputs are
#     `[ -f ]`-guarded and a missing one is fatal here.
#   * A head does NOT prove everything sorting before it is equal (Compare's
#     m_visited short-circuit), so the DUMP DIFF is the distance and the cmp
#     line count is reported as HEAD DEPTH ONLY.
set -u
G=${1:?golden.uhdm}
O=${2:?ours.uhdm}
TAG=${3:-t}
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
UC=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -f "$G" ] || { echo "FATAL: missing golden $G"; exit 9; }
[ -f "$O" ] || { echo "FATAL: missing ours   $O"; exit 9; }
OUT=${OUTDIR:-/tmp/r10oth7_d_$TAG}
mkdir -p "$OUT" || exit 9
"$UD" "$G" 2>/dev/null | sed '1d' > "$OUT/g.dump"
"$UD" "$O" 2>/dev/null | sed '1d' > "$OUT/o.dump"
[ -s "$OUT/g.dump" ] && [ -s "$OUT/o.dump" ] || { echo "FATAL: empty dump"; exit 7; }
"$UC" "$G" "$O" > "$OUT/cmp.log" 2>&1 && CMPV=PASS_CMP || CMPV=CMP_FAIL
CL=$(wc -l < "$OUT/cmp.log")
if diff -u "$OUT/g.dump" "$OUT/o.dump" > "$OUT/d.diff"; then
  C=0; H=0
else
  C=$(grep -E '^[-+]' "$OUT/d.diff" | grep -vcE '^(---|\+\+\+) ')
  H=$(grep -c '^@@' "$OUT/d.diff")
fi
echo "$TAG: $CMPV cmp_lines=$CL (HEAD DEPTH) dump_content=$C hunks=$H (DISTANCE) wd=$OUT"
echo "  head:"
head -6 "$OUT/cmp.log" | sed 's/^/    /'
