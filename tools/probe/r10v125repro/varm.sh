#!/usr/bin/env bash
# v125 verifier arm driver.  Golden = Surelog; RHS = ours.  Both views, both binaries.
# usage: PRIS=.. PATCHED=.. varm.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SCAN=${SCAN:-/tmp/v125_tools/v125scan}
PRIS=${PRIS:?}; PATCHED=${PATCHED:-}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log 2>&1 </dev/null ); echo "SLrc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
run(){ ( cd "$D" && "$2" "$B" $3 -o "$1.uhdm" > "$1.log" 2>&1 </dev/null ); echo "$1 rc=$?"; }
run o  "$PRIS" ""
run oe "$PRIS" "--elabuhdm"
if [ -n "$PATCHED" ]; then run q "$PATCHED" ""; run qe "$PATCHED" "--elabuhdm"; fi
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  "$SCAN" "$D/$t.uhdm" ARG 2>/dev/null | sort > "$D/$t.arg"
  "$SCAN" "$D/$t.uhdm" OP82 2>/dev/null | sort > "$D/$t.op82"
  "$SCAN" "$D/$t.uhdm" KIND 2>/dev/null | sort > "$D/$t.kind"
  echo "$t args=$(wc -l < "$D/$t.arg") op82=$(wc -l < "$D/$t.op82")"
done
for t in o q oe qe; do
  [ -f "$D/$t.uhdm" ] && [ -f "$D/g.uhdm" ] || continue
  "$CMP" "$D/g.uhdm" "$D/$t.uhdm" > "$D/$t.cmp" 2>&1
  echo "$t cmp rc=$? lines=$(wc -l < "$D/$t.cmp") heads=$(grep -c '^LHS:' "$D/$t.cmp"; true)"
done
echo "WD=$D"
