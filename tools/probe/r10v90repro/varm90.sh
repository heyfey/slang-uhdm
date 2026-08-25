#!/usr/bin/env bash
# r10v90 — ONE arm, THREE databases (Surelog golden, pristine, patched), BOTH
# views for our binaries, censused with ct90cen --inst and scored per cell.
# Every child gets </dev/null and its rc is RECORDED.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN90:?}; PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL      rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B" -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris    rc=$?"
( cd "$D" && "$PATCHED" "$B" -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc    rc=$?"
( cd "$D" && "$PRIS"    --elabuhdm "$B" -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE   rc=$?"
( cd "$D" && "$PATCHED" --elabuhdm "$B" -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE   rc=$?"
for t in g o q oe qe; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; }; done
for t in g o q oe qe; do [ -f "$D/$t.uhdm" ] && "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"; done
echo "-- rows: golden=$(wc -l < "$D/g.rows" 2>/dev/null) pris=$(wc -l < "$D/o.rows" 2>/dev/null) patched=$(wc -l < "$D/q.rows" 2>/dev/null) prisE=$(wc -l < "$D/oe.rows" 2>/dev/null) patchedE=$(wc -l < "$D/qe.rows" 2>/dev/null)"
