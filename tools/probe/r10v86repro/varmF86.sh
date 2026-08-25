#!/usr/bin/env bash
# r10v86 — same as varm86.sh but the PATCHED side is the VERIFIER-FIXED binary.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${PACEN86:?set PACEN86 to a built r10earl86repro/pacen86}
PRIS=${PRIS:?set PRIS to the frozen PRISTINE binary}
PATCHED=${PATCHED:?set PATCHED to the frozen binary built from the patch PLUS the verifier fix}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
E=${3:-}; SLX=""; OUX=""
if [ "$E" = elab ]; then SLX="-elabuhdm"; OUX="--elabuhdm"; fi
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv $SLX -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    --nobuiltin $OUX "$B" -o o.uhdm >o.log 2>&1 </dev/null ); echo "pris rc=$?"
( cd "$D" && "$PATCHED" --nobuiltin $OUX "$B" -o q.uhdm >q.log 2>&1 </dev/null ); echo "fixd rc=$?"
for t in g o q; do [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; exit 1; }; done
for t in g o q; do "$CEN" "$D/$t.uhdm" --inst 2>/dev/null > "$D/$t.rows"; done
echo "rows golden=$(wc -l < "$D/g.rows") pris=$(wc -l < "$D/o.rows") fixed=$(wc -l < "$D/q.rows")"
