#!/bin/bash
# § wildcardImportCopiesPkgVarsToDefNets223 — THE A-PRIORI PREDICTION.
#
# Re-runs EVERY row-mode's own recorded slang command line (read out of the
# pristine sweep's cmds.txt, so the arguments are the harness's, not this
# script's) with the PREDICTOR binary and SLANG223_PRED=1.  In that mode the
# binary DECLINES the new mint and only reports, per interface DEFINITION, the
# size of the hoist the law would add — so the databases it writes are
# byte-identical to the pristine sweep's (asserted here, per row) and the
# report is a genuine A-PRIORI prediction of the mover set.
#
#   usage: PRED=<pred binary> DIRS=<name-to-dir table> bash predict223.sh \
#              <pristine-workdir> <outfile>
#
# MINT223=1 unsets the env var and lets the SAME binary MINT — the control
# run, whose DBDIFF lines are the ACTUAL mover set under the law.
set -u
PRED=${PRED:?export PRED=<predictor binary>}
WD=${1:?pristine workdir}
OUT=${2:?outfile}
SCRATCH=${SCRATCH:-/tmp/r10uvm223_predscratch}
DIRS=${DIRS:?export DIRS=<name-to-dir table>}
CORPUS=${CORPUS:?export CORPUS=sl|u2r}
mkdir -p "$SCRATCH"
: > "$OUT"
n=0; same=0; diffdb=0; hit=0
while IFS= read -r c; do
    d=$(dirname "$c")
    mode=$(basename "$(dirname "$d")")
    name=$(basename "$d")
    line=$(sed -n 's/^slang:  *//p' "$c")
    [ -z "$line" ] && continue
    # drop the binary (field 1) and rebuild with ours + our own -o
    args=$(printf '%s\n' "$line" | cut -d' ' -f2-)
    args=$(printf '%s\n' "$args" | sed 's# -o [^ ]*##')
    odb="$SCRATCH/pred.uhdm"
    rm -f "$odb"
    err="$SCRATCH/pred.err"
    # The two corpora SHARE twelve test names (BitSelect, ConcatWidth, Disable,
    # EnumConcat, OneImport, SignedWire, ...), so the lookup is keyed on the
    # CORPUS TAG as well as the name.  A name-only lookup silently compiled the
    # OTHER corpus's sources and manufactured seven phantom movers.
    src=$(awk -v n="${name%-*}" -v c="$CORPUS" -F'\t' '$1==c && $2==n{print $3; exit}' "$DIRS")
    if [ -z "$src" ]; then echo "NODIR $mode $name" >> "$OUT"; continue; fi
    ( cd "$src" && if [ "${MINT223:-0}" = 1 ]; then unset SLANG223_PRED; else export SLANG223_PRED=1; fi && eval "\"$PRED\" $args -o \"$odb\"" > /dev/null 2> "$err" </dev/null )
    n=$((n+1))
    pdb="$d/slang.uhdm"
    if [ -f "$odb" ] && [ -f "$pdb" ]; then
        if cmp -s "$odb" "$pdb"; then same=$((same+1)); else diffdb=$((diffdb+1)); echo "DBDIFF $mode $name" >> "$OUT"; fi
    fi
    tot=$(awk '$1=="PRED223"{s+=$3} END{print s+0}' "$err")
    ifs=$(grep -c '^PRED223 ' "$err"; true)
    if [ "$tot" != 0 ]; then
        hit=$((hit+1))
        echo "HIT $mode $name ifaces=$ifs hoisted=$tot" >> "$OUT"
        awk -v m="$mode" -v t="$name" '$1=="PRED223" && $3+0>0 {print "  CELL " m " " t " " $2 " " $3}' "$err" >> "$OUT"
    fi
done < <(find "$WD" -name cmds.txt | sort)
echo "predict223: rows=$n  db-identical=$same  DB-DIFFERING=$diffdb  HIT-ROWS=$hit" | tee -a "$OUT"
