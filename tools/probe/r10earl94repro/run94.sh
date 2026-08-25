#!/usr/bin/env bash
# r10earl94 -- build ONE arm with Surelog (GOLDEN) and with a frozen binary,
# in BOTH views, and print every ref_obj cell keyed by (view,inst,span,parent).
# MEASUREMENT ONLY.  usage: run94.sh <file.sv> <outdir>   env: BIN [SLFLAGS]
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
BIN=${BIN:?set BIN}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
for V in plain elab; do
  EL=""; SEL=""
  [ "$V" = elab ] && { EL="-elabuhdm"; SEL="--elabuhdm"; }
  mkdir -p "$D/$V"; cp "$F" "$D/$V/"
  ( cd "$D/$V" && "$SL" -parse -nobuiltin -nocache -sv $EL -d uhdm ${SLFLAGS:-} "$B" >sl.log 2>&1 </dev/null ); echo "$V SL   rc=$?"
  [ -f "$D/$V/slpp_all/surelog.uhdm" ] && cp "$D/$V/slpp_all/surelog.uhdm" "$D/$V/g.uhdm"
  ( cd "$D/$V" && "$BIN" "$B" $SEL -o o.uhdm >o.log 2>&1 </dev/null ); echo "$V ours rc=$?"
done
