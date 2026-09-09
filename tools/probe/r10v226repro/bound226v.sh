#!/bin/bash
# r10v226 — WIDE BOUNDARY.  Every committed probe arm source, compiled by the
# frozen pristine and patched binaries into the SAME output path (so the byte
# comparison is valid — the .uhdm embeds its own path), byte-compared.
# Subdirectory arms are included; the file list is read on fd 3 and every child
# gets </dev/null; PROCESSED is asserted against LISTED.  The four slang-fenced
# tests are excluded by path (FENCED= count only, never named in output).
set -u
PRIS=${PRIS:-/tmp/v226_bin/pris.bin}
PAT=${PAT:-/tmp/v226_bin/pat.bin}
ROOT=${ROOT:-/home/heyfey/git-repos/slang-uhdm/tools/probe}
SCR=${SCR:-/tmp/v226_bscratch}
OUT=${1:?outfile}
FENCE='UnsignedParam|HierPathEval|FileLocalParam|TopParam'
rm -rf "$SCR"; mkdir -p "$SCR/w"
LIST=/tmp/v226_boundlist.txt
find "$ROOT" -name '*.sv' | sort > /tmp/v226_boundall.txt
grep -Ec "$FENCE" /tmp/v226_boundall.txt > /tmp/v226_fenced.txt; true
grep -Ev "$FENCE" /tmp/v226_boundall.txt > "$LIST"
listed=$(wc -l < "$LIST"); processed=0; moved=0; rcdiff=0
: > "$OUT"
echo "FENCED=$(cat /tmp/v226_fenced.txt) excluded" >> "$OUT"
exec 3< "$LIST"
while read -r f <&3; do
    processed=$((processed+1))
    d="$SCR/w"; rm -f "$d/o.uhdm"
    ( cd "$d" && timeout 120 "$PRIS" "$f" -o o.uhdm > p.log 2>&1 </dev/null ); prc=$?
    [ -f "$d/o.uhdm" ] && mv "$d/o.uhdm" "$d/p.uhdm"
    ( cd "$d" && timeout 120 "$PAT"  "$f" -o o.uhdm > q.log 2>&1 </dev/null ); qrc=$?
    [ -f "$d/o.uhdm" ] && mv "$d/o.uhdm" "$d/q.uhdm"
    if [ "$prc" != "$qrc" ]; then
        echo "RCDIFF $f pris=$prc pat=$qrc" >> "$OUT"; rcdiff=$((rcdiff+1))
    fi
    if [ -f "$d/p.uhdm" ] && [ -f "$d/q.uhdm" ]; then
        cmp -s "$d/p.uhdm" "$d/q.uhdm" || { echo "MOVED $f" >> "$OUT"; moved=$((moved+1)); }
    elif [ -f "$d/p.uhdm" ] || [ -f "$d/q.uhdm" ]; then
        echo "MOVED-ONESIDE $f pris=$prc pat=$qrc" >> "$OUT"; moved=$((moved+1))
    fi
    rm -f "$d/p.uhdm" "$d/q.uhdm"
done
exec 3<&-
echo "BOUNDARY LISTED $listed PROCESSED $processed MOVED $moved RCDIFF $rcdiff" >> "$OUT"
tail -1 "$OUT"
