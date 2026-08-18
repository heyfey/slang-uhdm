#!/usr/bin/env bash
# r10v69 — build one arm with Surelog (golden) and with BOTH frozen binaries in
# BOTH views, then census with hpname69.  MEASUREMENT ONLY.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
HP=${HPNAME:?set HPNAME to the built hpname69}
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
mkdir -p "$D"; cp "$F" "$D/"
norm() { sed -E 's/,?span=[^ ,;}|]*//g'; }
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && "$HP" "$D/slpp_all/surelog.uhdm" 2>/dev/null > "$D/g.hp" || : > "$D/g.hp"
for s in pris pat; do
  bin=$PRIS; [ $s = pat ] && bin=$PAT
  for v in plain elab; do
    fl=""; [ $v = elab ] && fl="--elabuhdm"
    ( cd "$D" && "$bin" $fl "$B" -o $s$v.uhdm >$s$v.log 2>&1 </dev/null ); echo "$s $v rc=$?"
    [ -f "$D/$s$v.uhdm" ] && "$HP" "$D/$s$v.uhdm" 2>/dev/null > "$D/$s$v.hp" || : > "$D/$s$v.hp"
  done
done
wc -l "$D"/*.hp
