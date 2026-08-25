#!/usr/bin/env bash
# r10v91 verifier arm runner. usage: varm.sh <file.sv> <outdir> [extra surelog args]
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=${CEN91:?set CEN91 to a built ct91pat}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
shift 2
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$@" "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B" -o o.uhdm >o.log 2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PATCHED" "$B" -o q.uhdm >q.log 2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PRIS"    --elabuhdm "$B" -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" --elabuhdm "$B" -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g o q; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; exit 1; }; done
for t in g o q oe qe; do [ -f "$D/$t.uhdm" ] && "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"; done
echo "-- rows: golden=$(wc -l < "$D/g.rows") pris=$(wc -l < "$D/o.rows") patched=$(wc -l < "$D/q.rows")"
