#!/bin/bash
# r11u109 — score one DIFFERS arm of the wide boundary: a fresh Surelog v1.87
# golden, a NULL re-run of the pristine binary, and the path-keyed cell scorer
# (cells109.py) on golden / pristine / law dumps.
# usage: BND_OUT=<dir> BND_ROOT=<probe dir> BND_PRIS=<bin> bndscore109.sh <arm rel path>
set -u
A=$1; K=$(printf '%s' "$A" | tr '/.' '__'); D=$BND_OUT/$K; F=$BND_ROOT/$A
H=$(dirname "$(readlink -f "$0")")
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
rm -rf "$D/g"; mkdir -p "$D/g"
( cd "$D/g" && timeout 600 "$SL" -parse -nobuiltin -nocache -sv "$F" -mt 0 -mp 0 -o . > sl.log 2>&1 ); slrc=$?
slerr=$(grep -c '\[ERR' "$D/g/sl.log"; true)
G=$(ls "$D"/g/slpp_all/*.uhdm 2>/dev/null | head -1)
( cd "$D" && timeout 300 "$BND_PRIS" "$F" --single-unit -o out.uhdm > n.log 2>&1 )
null=DIFF; cmp -s "$D/out.uhdm" "$D/pris.uhdm" && null=SAME; rm -f "$D/out.uhdm"
for t in pris law; do timeout 600 "$DUMP" "$D/$t.uhdm" 2>/dev/null | sed "s#$D##g" > "$D/$t.dump"; done
if [ -n "$G" ]; then timeout 600 "$DUMP" "$G" 2>/dev/null | sed "s#$D##g" > "$D/g.dump"
  sc=$(python3 "$H/cells109.py" "$D/g.dump" "$D/pris.dump" "$D/law.dump")
  cl="$(wc -l < <("$HOME/git-repos/UHDM/build/bin/uhdm-cmp" "$G" "$D/pris.uhdm" 2>&1))->$(wc -l < <("$HOME/git-repos/UHDM/build/bin/uhdm-cmp" "$G" "$D/law.uhdm" 2>&1))"
else sc="NOGOLD"; cl=NA; fi
echo "ARM $A slrc=$slrc slerr=$slerr null=$null cmp=$cl $sc"
