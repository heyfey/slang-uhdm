#!/usr/bin/env bash
# r10v84 — one arm, FOUR databases: golden, pristine, as-submitted, FIXED.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN84:?}; PRIS=${PRIS:?}; PATCHED=${PATCHED:?}; FIXED=${FIXED:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL   rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B" -o o.uhdm >o.log 2>&1 </dev/null ); echo "pris rc=$?"
( cd "$D" && "$PATCHED" "$B" -o q.uhdm >q.log 2>&1 </dev/null ); echo "subm rc=$?"
( cd "$D" && "$FIXED"   "$B" -o f.uhdm >f.log 2>&1 </dev/null ); echo "fix  rc=$?"
for t in g o q f; do [ -f "$D/$t.uhdm" ] && "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"; done
echo "-- rows: g=$(wc -l < "$D/g.rows") o=$(wc -l < "$D/o.rows") q=$(wc -l < "$D/q.rows") f=$(wc -l < "$D/f.rows")"
