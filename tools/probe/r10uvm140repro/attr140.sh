#!/usr/bin/env bash
# r10uvm140 — ORDER-BLIND attribution of ONE byte mover: dump the pristine and
# the patched database, erase the workdir path (dump paths embed it), SORT both
# (Scoreboard/default is a ~50/50 coin per invocation, so only an order-blind
# read may be attributed), and print the symmetric difference.
# MEASUREMENT ONLY — the judge is the official uhdm-cmp.
#   usage: attr140.sh <pristine-wd> <patched-wd> <mode/dir> <outdir>
set -u
PW=${1:?}; QW=${2:?}; REL=${3:?}; OUT=${4:?}; mkdir -p "$OUT"
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
key=$(echo "$REL" | tr '/' '_')
"$DUMP" "$PW/$REL/slang.uhdm" 2>&1 | sed "s#$PW/##g" | sort > "$OUT/$key.pris.srt"
"$DUMP" "$QW/$REL/slang.uhdm" 2>&1 | sed "s#$QW/##g" | sort > "$OUT/$key.pat.srt"
diff "$OUT/$key.pris.srt" "$OUT/$key.pat.srt" > "$OUT/$key.diff"; rc=$?
echo "ATTR $REL difflines=$(grep -c '^[<>]' "$OUT/$key.diff"; true) rc=$rc"
grep '^[<>]' "$OUT/$key.diff" | sort | uniq -c | sort -rn | head -40
rm -f "$OUT/$key.pris.srt" "$OUT/$key.pat.srt"
