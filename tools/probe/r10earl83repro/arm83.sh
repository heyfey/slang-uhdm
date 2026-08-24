#!/usr/bin/env bash
# r10earl83 — build ONE arm with Surelog (GOLDEN) and with the TWO FROZEN
# binaries, census all three with ct83cen over the UNION of their cast spans,
# and score every cell.  MEASUREMENT ONLY; the official uhdm-cmp stays the
# judge on the corpus.
#   usage: arm83.sh <file.sv> <outdir>
#   env:   SURELOG PRIS PATCHED CEN83
# Every child gets </dev/null and its rc is RECORDED (an rc=139 that leaves a
# short .uhdm behind must never read as "no difference").
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN83:?set CEN83}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B" -o o.uhdm >o.log 2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PATCHED" "$B" -o q.uhdm >q.log 2>&1 </dev/null ); echo "patc  rc=$?"
for t in g o q; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; exit 1; }; done
for t in g o q; do "$CEN" "$D/$t.uhdm" --spans 2>/dev/null > "$D/$t.span"; done
sort -u "$D"/g.span "$D"/o.span "$D"/q.span > "$D/all.span"
for t in g o q; do "$CEN" "$D/$t.uhdm" --at "$D/all.span" 2>/dev/null > "$D/$t.rows"; done
echo "-- spans: golden=$(wc -l < "$D/g.span") pris=$(wc -l < "$D/o.span") patched=$(wc -l < "$D/q.span") union=$(wc -l < "$D/all.span")"
