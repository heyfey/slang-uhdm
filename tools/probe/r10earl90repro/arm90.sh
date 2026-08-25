#!/usr/bin/env bash
# r10earl84 — build ONE arm with Surelog (GOLDEN) and with the TWO FROZEN
# binaries, census all three with ct84cen, and score every cell three ways.
# MEASUREMENT ONLY; the official uhdm-cmp stays the judge on the corpus.
#   usage: arm84.sh <file.sv> <outdir>
#   env:   SURELOG PRIS PATCHED CEN84
# Every child gets </dev/null and its rc is RECORDED (an rc=139 that leaves a
# short .uhdm behind must never read as "no difference").
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN84:?set CEN84}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B" -o o.uhdm >o.log 2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PATCHED" "$B" -o q.uhdm >q.log 2>&1 </dev/null ); echo "patc  rc=$?"
for t in g o q; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; exit 1; }; done
for t in g o q; do "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"; done
echo "-- rows: golden=$(wc -l < "$D/g.rows") pris=$(wc -l < "$D/o.rows") patched=$(wc -l < "$D/q.rows")"
