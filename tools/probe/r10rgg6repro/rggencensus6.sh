#!/usr/bin/env bash
# r10rgg6/rggencensus6.sh — the func_call vpiTypespec census, golden vs ours,
# over a whole database.  Keyed (view, enclosing instance path, callee name,
# line:col, ts?, ts actual kind@loc) — never fullname, never span.
#
#   usage: rggencensus6.sh <golden.uhdm> <ours.uhdm> <outdir>
set -u
G=${1:?golden uhdm}
O=${2:?ours uhdm}
OUT=${3:?outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
[ -f "$G" ] || { echo "FATAL: no golden $G"; exit 3; }
[ -f "$O" ] || { echo "FATAL: no ours $O"; exit 3; }
mkdir -p "$OUT"
"$DUMP" "$G" > "$OUT/g.dump" 2>&1
"$DUMP" "$O" > "$OUT/o.dump" 2>&1
python3 "$HERE/dumpscan.py" "$OUT/g.dump" allcalls | LC_ALL=C sort > "$OUT/g.calls"
python3 "$HERE/dumpscan.py" "$OUT/o.dump" allcalls | LC_ALL=C sort > "$OUT/o.calls"
echo "golden func_calls=$(wc -l < "$OUT/g.calls")  ours=$(wc -l < "$OUT/o.calls")"
echo "-- golden ts histogram"; awk -F'\t' '{print $1"\t"$5}' "$OUT/g.calls" | sort | uniq -c
echo "-- ours   ts histogram"; awk -F'\t' '{print $1"\t"$5}' "$OUT/o.calls" | sort | uniq -c
echo "-- MULTISET diff (golden-only < , ours-only >), first 60"
diff "$OUT/g.calls" "$OUT/o.calls" | grep -E '^[<>]' | head -60
echo "-- diff sides = $(diff "$OUT/g.calls" "$OUT/o.calls" | grep -cE '^[<>]' || true)"
