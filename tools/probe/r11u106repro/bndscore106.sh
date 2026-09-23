#!/bin/bash
# r11u106 — score one DIFFERS arm of the wide boundary: a fresh Surelog v1.87
# golden, tw106 on golden / pristine / law, score106.py per cell, the law
# attribution of every moved cell (S = the pattern op typespec, M = the
# typedef'd array variable), and a NULL re-run of the pristine binary.
# usage: BND_OUT=<dir> BND_ROOT=<probe dir> BND_PRIS=<bin> bndscore106.sh <arm rel path>
set -u
A=$1; K=$(printf '%s' "$A" | tr '/.' '__'); D=$BND_OUT/$K; F=$BND_ROOT/$A
H=$(dirname "$(readlink -f "$0")"); TW=${TW106:-/tmp/r11u106_tw}
SL=$HOME/git-repos/Surelog/build/bin/surelog
rm -rf "$D/g"; mkdir -p "$D/g"
( cd "$D/g" && timeout 600 "$SL" -parse -nobuiltin -nocache -sv "$F" -mt 0 -mp 0 -o . > sl.log 2>&1 ); slrc=$?
slerr=$(grep -c '\[ERR' "$D/g/sl.log"; true)
G=$(ls "$D"/g/slpp_all/*.uhdm 2>/dev/null | head -1)
( cd "$D" && timeout 300 "$BND_PRIS" "$F" --single-unit -o out.uhdm > n.log 2>&1 )
null=DIFF; cmp -s "$D/out.uhdm" "$D/pris.uhdm" && null=SAME; rm -f "$D/out.uhdm"
for t in pris law; do "$TW" "$D/$t.uhdm" | sed 's/#[0-9]*//g' > "$D/$t.tw"; done
if [ -n "$G" ]; then "$TW" "$G" | sed 's/#[0-9]*//g' > "$D/g.tw"; sc=$(python3 "$H/score106.py" "$D/g.tw" "$D/pris.tw" "$D/law.tw" | tail -1); else sc="NOGOLD"; fi
mv=$(diff "$D/pris.tw" "$D/law.tw" | grep '^>' | cut -f1)
nS=$(printf '%s\n' "$mv" | grep -c '\.rhs/operation7[56]@[^/]*\.ts/struct_typespec'; true)
nM=$(printf '%s\n' "$mv" | grep -c '/var([^)]*)/array_typespec'; true)
nAll=$(printf '%s\n' "$mv" | grep -c .; true)
echo "ARM $A slrc=$slrc slerr=$slerr null=$null moved=$nAll S=$nS M=$nM $sc"
