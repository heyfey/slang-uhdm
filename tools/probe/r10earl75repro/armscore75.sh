#!/usr/bin/env bash
# r10earl75 — build ONE arm with Surelog (golden) and with the two FROZEN
# binaries, in BOTH views, census each with cscen75 and score the patched side
# against golden with score75.py.  A moved arm is acceptable only if it moves
# TOWARD golden: AWAY-GOLDEN must be 0.
# MEASUREMENT ONLY.  usage: armscore75.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CSCEN75:?set CSCEN75}; SCORE=${SCORE75:?set SCORE75}
NORM=${NORM75:?set NORM75}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null )
echo "SL rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; continue; }
  LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$CEN" "$D/$t.uhdm" 2>/dev/null \
    | bash "$NORM" /dev/stdin > "$D/$t.n"
done
echo "-- default view (g/o/q):"    ; python3 "$SCORE" "$D/g.n" "$D/o.n"  "$D/q.n"  9 40
echo "-- elabuhdm view (g/oe/qe):" ; python3 "$SCORE" "$D/g.n" "$D/oe.n" "$D/qe.n" 9 40
