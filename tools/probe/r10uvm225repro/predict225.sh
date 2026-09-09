#!/usr/bin/env bash
# r10uvm225 — THE A-PRIORI MOVER PREDICTION, per corpus row.
#
# Re-runs the PATCHED binary with `R10E225_DBG=1` on the EXACT command line the
# harness recorded in each row's `cmds.txt`, into a scratch directory of its
# own, and collects the `R10E225` trace lines.  The trace writes nothing to the
# database — proved by hand (`a.uhdm` and `b.uhdm` byte-identical with and
# without the variable) and by this script's own `-o` going to scratch — so the
# rows it names are a PREDICTION of the mover set, made before the patched
# sweep is scored.
#
# Every line the law can be responsible for is traced:
#   MINT     an array_net was minted  (pris=1 when the pristine gate would
#            have minted one too, so a `pris=0` line is a NEW object and a
#            `pris=1` line can still move on its inner net's `vpiNetType`)
#   REMOVE   the WRITTEN-DIMENSION gate declined one the pristine gate minted
#   RA-FLIP  the associative reprieve's verdict differs from r10uvm224's
#
# A row with NO trace line cannot move: the patch changes nothing else.
#
#   usage: predict225.sh <workdir-with-cmds.txt> <scratch> <out>
set -u
WD=${1:?workdir}; SCR=${2:?scratch}; OUT=${3:?out}
BIN=${SLANG_UHDM:?export SLANG_UHDM to the PATCHED binary}
rm -rf "$SCR"; mkdir -p "$SCR" || exit 1
: > "$OUT"
LIST=$SCR/list.txt
find "$WD" -name cmds.txt | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; hit=0
while read -r c <&3; do
    proc=$((proc+1))
    row=$(basename "$(dirname "$c")")
    mode=$(basename "$(dirname "$(dirname "$c")")")
    line=$(grep -m1 '^slang:' "$c" | sed 's/^slang: *//')
    [ -n "$line" ] || { echo "NOCMD $mode/$row" >> "$OUT"; continue; }
    # Re-point the output at OUR scratch: the recorded `-o <path>` names the
    # harness's own database and must never be overwritten.
    d=$SCR/$mode-$row; mkdir -p "$d"
    newline=$(echo "$line" | sed "s#-o [^ ]*#-o $d/pred.uhdm#")
    # ...and the recorded binary is replaced by the pinned patched one.
    newline=$(echo "$newline" | sed "s#^[^ ]*#$BIN#")
    ( cd "$d" && R10E225_DBG=1 timeout 900 bash -c "$newline" > out.log 2> err.log </dev/null )
    rc=$?
    n=$(grep -c '^R10E225 ' "$d/err.log" 2>/dev/null || true)
    if [ "${n:-0}" != 0 ]; then
        hit=$((hit+1))
        echo "ROW $mode/$row rc=$rc lines=$n" >> "$OUT"
        grep '^R10E225 ' "$d/err.log" | sed "s#^#  $mode/$row #" >> "$OUT"
    fi
    rm -f "$d/pred.uhdm"
done 3< "$LIST"
echo "-- LISTED=$listed PROCESSED=$proc HIT_ROWS=$hit" >> "$OUT"
tail -1 "$OUT"
[ "$listed" -eq "$proc" ] || { echo "FATAL: LISTED != PROCESSED"; exit 4; }
