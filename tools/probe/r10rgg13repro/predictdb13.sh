#!/usr/bin/env bash
# r10rgg13/predictdb13.sh — THE DATABASE-LEVEL PREDICTION, run on a PRISTINE
# BASE workdir BEFORE the patched sweep is read.
#
#   usage: predictdb13.sh <verify_golden workdir> <outfile>
#
# For every (mode,test) directory that has BOTH databases it runs the call-argument
# census (acensus13) on each side and prints every ELAB call-ARGUMENT row inside a
# `param_assign` Rhs where OUR side is a CONSTANT parented at the `func_call` —
# i.e. every row where the fold § genLpPaCallArgCopy13 replaces actually fired,
# whether or not it currently disagrees with golden.  That predicate is an
# OVER-INCLUSIVE SUPERSET of the law (it does not test that the written actual was
# a bare parameter name, nor that the source `param_assign` Rhs is a constant),
# which is the safe direction for a prediction: every row the patch can move is in
# it.
#
# GUARDS: a directory missing either database prints SKIP-NOFILE and is COUNTED;
# the golden path is read out of the workdir's own cmds.txt so the wrong golden
# can never be compared silently.
#
# THE FENCE: the four slang-fenced tests are skipped by this one expression and
# COUNTED, never dispatched and never spelled one at a time.
set -u
WD=${1:?workdir}
OUT=${2:?outfile}
CEN=/tmp/r10rgg13_acensus
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
: > "$OUT"
scanned=0; skip=0; fenced=0
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
    "$CEN" "$G" 2>/dev/null | grep '^ELAB|ARG|' | LC_ALL=C sort > /tmp/r10rgg13_pd_g.$$
    "$CEN" "$O" 2>/dev/null | grep '^ELAB|ARG|' | LC_ALL=C sort > /tmp/r10rgg13_pd_o.$$
    # LEFT join on OUR rows: a row we emit that golden does not have at all is
    # still a row this patch can move, so it must not be dropped by the join.
    join -t $'\t' -a 1 -e '<absent>' -o 0,1.2,2.2 \
         /tmp/r10rgg13_pd_o.$$ /tmp/r10rgg13_pd_g.$$ 2>/dev/null |
      awk -F'\t' -v m="$mode" -v n="$n" '
        $2 ~ /^const\(.*\/P:func_call@/ {
          print "PREDICT " m "/" n " " $1 "  OURS=" substr($2,1,90) "  GOLD=" substr($3,1,90) }' >> "$OUT"
    rm -f /tmp/r10rgg13_pd_g.$$ /tmp/r10rgg13_pd_o.$$
  done
done
rows=$(grep -c '^PREDICT ' "$OUT"; true)
echo "-- dirs-scanned=$scanned SKIP-NOFILE=$skip FENCED-SKIP=$fenced PREDICTED-ROWS=$rows" | tee -a "$OUT"
