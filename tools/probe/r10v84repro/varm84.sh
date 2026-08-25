#!/usr/bin/env bash
# r10v84 (VERIFIER) — build ONE arm with Surelog (GOLDEN) and with the TWO
# FROZEN binaries, keep BOTH the raw uhdm-dump text (path-normalised) AND the
# ct84cen rows, so the arm verdict never depends on the implementer's own
# instrument alone.  MEASUREMENT ONLY.
#   usage: varm84.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${CEN84:?}; PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B" -o o.uhdm >o.log 2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PATCHED" "$B" -o q.uhdm >q.log 2>&1 </dev/null ); echo "patc  rc=$?"
for t in g o q; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; continue; }; done
for t in g o q; do
  [ -f "$D/$t.uhdm" ] || continue
  "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"
  "$DUMP" "$D/$t.uhdm" 2>/dev/null | sed "s#$D/##g; s#$HOME#~#g" > "$D/$t.dump"
done
echo "-- rows: golden=$(wc -l < "$D/g.rows" 2>/dev/null) pris=$(wc -l < "$D/o.rows" 2>/dev/null) patched=$(wc -l < "$D/q.rows" 2>/dev/null)"
