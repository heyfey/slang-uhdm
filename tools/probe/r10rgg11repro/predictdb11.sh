#!/usr/bin/env bash
# r10rgg11/predictdb11.sh — THE DATABASE-LEVEL PREDICTION, run on a PRISTINE
# BASE workdir BEFORE the patched sweep is read.
#
#   usage: predictdb11.sh <verify_golden workdir> <outfile>
#
# For every (mode,test) directory that has BOTH databases it runs the
# port-actual census (pcensus11) on each side and prints every ELAB port
# connection whose actual is, ON OUR SIDE, the 64-bit UINT fold that
# § genLpPortConnValue11 replaces — `constant(UINT:*,sz=64,ct=9,...)` — and
# whose GOLDEN counterpart is a DIFFERENT constant.  That predicate is an
# OVER-INCLUSIVE SUPERSET of the law (other arms also mint sz=64/ct=9
# constants), which is the safe direction for a prediction.
#
# GUARDS: a directory missing either database prints SKIP-NOFILE and is
# COUNTED; the golden path is read out of the workdir's own cmds.txt so the
# wrong golden can never be compared silently.
#
# THE FENCE: the four slang-fenced tests
# (UnsignedParam|HierPathEval|FileLocalParam|TopParam) are skipped by this one
# expression and COUNTED, never dispatched and never spelled one at a time.
set -u
WD=${1:?workdir}
OUT=${2:?outfile}
CEN=/tmp/r10rgg11_pcensus
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
: > "$OUT"
scanned=0; skip=0; fenced=0; rows=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d"); n=${n%-*}
    case "$n" in
      UnsignedParam|HierPathEval|FileLocalParam|TopParam)
        fenced=$((fenced+1)); continue ;;
    esac
    O=$d/slang.uhdm
    G=""
    [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "SKIP-NOFILE $mode/$n" >> "$OUT"; skip=$((skip+1)); continue
    fi
    scanned=$((scanned+1))
    "$CEN" "$G" 2>/dev/null | grep '^ELAB|PORT|' | LC_ALL=C sort > /tmp/r10rgg11_pd_g.$$
    "$CEN" "$O" 2>/dev/null | grep '^ELAB|PORT|' | LC_ALL=C sort > /tmp/r10rgg11_pd_o.$$
    join -t $'\t' /tmp/r10rgg11_pd_o.$$ /tmp/r10rgg11_pd_g.$$ 2>/dev/null |
      awk -F'\t' -v m="$mode" -v n="$n" '
        $2 ~ /^constant\(UINT:[^,]*,sz=64,ct=9,/ && $2 != $3 {
          print "PREDICT " m "/" n " " $1 "  OURS=" $2 "  GOLD=" $3 }' >> "$OUT"
    rm -f /tmp/r10rgg11_pd_g.$$ /tmp/r10rgg11_pd_o.$$
  done
done
rows=$(grep -c '^PREDICT ' "$OUT"; true)
echo "-- dirs-scanned=$scanned SKIP-NOFILE=$skip FENCED-SKIP=$fenced PREDICTED-ROWS=$rows" | tee -a "$OUT"
