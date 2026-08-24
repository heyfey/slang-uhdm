#!/usr/bin/env bash
# r10earl80 — build ONE DIRECTORY as a single compilation unit with Surelog
# (golden) and with the frozen binaries, both views, and census with pacen80.
# MEASUREMENT ONLY.   usage: PACEN80=.. PRIS=.. PATCHED=.. armdir80.sh <dir> <out>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${PACEN80:?}; PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
S=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2")
cp "$S"/*.sv "$D/" 2>/dev/null
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv *.sv >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$PRIS"    *.sv            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    *.sv --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" *.sv            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" *.sv --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
( cd "$D" && R10E80_OFF=1 "$PATCHED" *.sv -o n.uhdm >n.log 2>&1 </dev/null ); echo "neutr rc=$?"
for t in g o oe q qe n; do [ -f "$D/$t.uhdm" ] && "$CEN" "$D/$t.uhdm" 2>/dev/null > "$D/$t.pa"; done
echo "WD=$D"
