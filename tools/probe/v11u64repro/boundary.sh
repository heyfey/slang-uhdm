#!/usr/bin/env bash
# v11u64 WIDE BOUNDARY — every committed probe arm that holds an assignment
# pattern, compiled by BOTH frozen binaries, databases compared byte-for-byte.
# Scratch is keyed on the arm's RELATIVE path (three `dut.sv` live in the tree).
# PROCESSED must equal LISTED.
set -u
ROOT=/tmp/wt_v11u64pris
OUT=/tmp/v11u64_scratch/bnd
LIST=/tmp/v11u64_scratch/bnd.list
rm -rf "$OUT"; mkdir -p "$OUT"
(cd "$ROOT" && grep -rl "'{" --include='*.sv' tools/probe | sort) > "$LIST"
n=$(wc -l < "$LIST"); echo "LISTED=$n"
proc=0; movers=0; fail=0
while read -r rel <&3; do
    d="$OUT/$(echo "$rel" | tr '/' '_')"
    mkdir -p "$d"
    src="$ROOT/$rel"
    (cd "$(dirname "$src")" && /tmp/v11u64_bin/pris "$(basename "$src")" --single-unit --nobuiltin \
        -o "$d/pris.uhdm" > "$d/pris.log" 2>&1 </dev/null); rp=$?
    (cd "$(dirname "$src")" && /tmp/v11u64_bin/law "$(basename "$src")" --single-unit --nobuiltin \
        -o "$d/law.uhdm" > "$d/law.log" 2>&1 </dev/null); rl=$?
    proc=$((proc+1))
    if [ "$rp" != "$rl" ]; then echo "RC_DIFF $rel pris=$rp law=$rl"; fail=$((fail+1)); continue; fi
    if [ -f "$d/pris.uhdm" ] && [ -f "$d/law.uhdm" ]; then
        if ! cmp -s "$d/pris.uhdm" "$d/law.uhdm"; then
            echo "MOVER $rel rc=$rp"
            movers=$((movers+1))
        else
            rm -f "$d/pris.uhdm" "$d/law.uhdm"
        fi
    fi
done 3< "$LIST"
echo "PROCESSED=$proc LISTED=$n MOVERS=$movers RC_DIFF=$fail"
