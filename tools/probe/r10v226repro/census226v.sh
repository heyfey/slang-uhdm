#!/bin/bash
# r10v226 — OVER-MINT CENSUS.  Replays every recorded slang command from a
# sweep workdir with R10E226_DBG=1 (proved write-free: identical .uhdm md5 with
# and without), redirecting the output to scratch so the sweep's own databases
# are never touched, and counts MINT226 / RAFOR226 hits per row.
set -u
WD=${1:?workdir}
OUT=${2:?outfile}
BIN=${BIN:-/tmp/v226_bin/pat.bin}
SCR=${SCR:-/tmp/v226_censcratch}
rm -rf "$SCR"; mkdir -p "$SCR"
LIST=$SCR/list.txt
find "$WD" -name cmds.txt | sort > "$LIST"
listed=$(wc -l < "$LIST"); processed=0; hit=0
: > "$OUT"
exec 3< "$LIST"
while read -r c <&3; do
    processed=$((processed+1))
    line=$(grep -m1 '^slang: ' "$c")
    [ -n "$line" ] || { echo "NOSLANG $c" >> "$OUT"; continue; }
    # strip the label, redirect -o to scratch, and run from the recorded dir
    cmd=${line#slang: }
    dir=$(dirname "$c")
    newcmd=$(python3 - "$cmd" "$SCR/o.uhdm" <<'PY'
import sys, shlex
a = shlex.split(sys.argv[1])
for i, t in enumerate(a):
    if t == '-o' and i + 1 < len(a):
        a[i + 1] = sys.argv[2]
print(shlex.join(a))
PY
)
    err=$SCR/e.txt
    ( cd "$dir" && eval "R10E226_DBG=1 timeout 900 $newcmd" > /dev/null 2> "$err" </dev/null )
    rc=$?
    m=$(grep -c '^MINT226' "$err"); true
    r=$(grep -c '^RAFOR226' "$err"); true
    if [ "$m" != 0 ] || [ "$r" != 0 ]; then
        hit=$((hit+1))
        echo "HIT ${dir#$WD/} rc=$rc MINT226=$m RAFOR226=$r" >> "$OUT"
        grep -h '^MINT226\|^RAFOR226' "$err" | sort | uniq -c | sed 's/^/    /' >> "$OUT"
    fi
done
exec 3<&-
echo "CENSUS $WD LISTED $listed PROCESSED $processed HIT_ROWS $hit" >> "$OUT"
# POSITIVE CONTROL — a census that cannot SEE reports zero exactly like a clean
# corpus.  Compile a source known to mint and assert the instrument fires.
pc=$(cd "$SCR" && R10E226_DBG=1 "$BIN" /tmp/v226_arms/b02_kinds/dut.sv -o pc.uhdm 2>&1 >/dev/null | grep -c '^MINT226'); true
echo "POSITIVE_CONTROL MINT226=$pc (must be 6)" >> "$OUT"
[ "$pc" = 6 ] || echo "  !! POSITIVE CONTROL FAILED — this census is BLIND" >> "$OUT"
tail -2 "$OUT"
