#!/usr/bin/env bash
# r10uvm129 — A-PRIORI MOVER PREDICTOR / CORPUS CENSUS.
# For every PRISTINE slang.uhdm in a verify_golden workdir it finds the GOLDEN
# from that row's OWN cmds.txt, censuses BOTH with cen129 and scores them with
# score129.py.  A database is a PREDICTED MOVER iff it holds at least one LAW
# cell: an array_var whose ELEMENT VARIABLE's vpiSigned disagrees with golden.
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
#   usage: CEN129=.. SCORE129=.. [PRED_OUT=dir] pred129.sh <workdir> [more...]
set -u
CEN=${CEN129:?set CEN129}
SC=${SCORE129:?set SCORE129}
OUT=${PRED_OUT:-}
SCRATCH=${PRED_SCRATCH:-/tmp/r10uvm129_pred_scratch}
mkdir -p "$SCRATCH"
tot=0; hit=0; ts=0; nog=0; parsed=0
[ -n "$OUT" ] && mkdir -p "$OUT"
for WD in "$@"; do
  while IFS= read -r db; do
    tot=$((tot+1))
    d=$(dirname "$db")
    tag=$(echo "$d" | sed 's#.*/\([^/]*\)/\([^/]*\)$#\1/\2#')
    G=""
    [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ]; then nog=$((nog+1)); continue; fi
    gc=$SCRATCH/g.cen; oc=$SCRATCH/o.cen
    "$CEN" "$G"  > "$gc" 2>/dev/null
    "$CEN" "$db" > "$oc" 2>/dev/null
    S=$(python3 "$SC" "$gc" "$oc" 2>/dev/null | grep '^PRIS ')
    # r10v129 FIX: score129.py's PRIS line spells the law counter LAW-WRONG=<n>
    # (and has no LAW= / LAW+TSSPAN= label at all), so the earlier extraction
    # matched nothing and this script could only ever print
    # PREDICTED_MOVERS=0 — a SILENT ZERO that would have made the post-patch
    # "not one law cell left" line vacuous.  PARSED= below is the guard: it
    # counts the PRIS lines actually seen, so a future label rename shows up
    # as PARSED < SCANNED instead of as a quiet 0.
    [ -n "$S" ] && parsed=$((parsed+1))
    N=$(echo "$S" | grep -o 'LAW-WRONG=[0-9]*' | cut -d= -f2); N=${N:-0}
    T=$(echo "$S" | grep -o ' TSSPAN=[0-9]*' | cut -d= -f2); T=${T:-0}
    if [ -n "$OUT" ]; then cp "$gc" "$OUT/$(echo "$tag"|tr / _).g.cen"; cp "$oc" "$OUT/$(echo "$tag"|tr / _).o.cen"; fi
    [ "$T" -gt 0 ] && ts=$((ts+1))
    if [ "$N" -gt 0 ]; then hit=$((hit+1)); echo "PREDICT law=$N tsspan=$T $tag"; fi
  done < <(find "$WD" -name 'slang.uhdm' | sort)
done
rm -f "$SCRATCH/g.cen" "$SCRATCH/o.cen"
echo "SCANNED=$tot PARSED=$parsed PREDICTED_MOVERS=$hit WITH_TSSPAN=$ts NO_GOLDEN=$nog"
