#!/usr/bin/env bash
# r10v99 verifier arm driver: runs BOTH frozen binaries on one source in one
# view, dumps golden + both, and reports (a) pristine-vs-candidate dump delta,
# (b) each side's official uhdm-cmp head depth against golden, (c) a
# normalised dump DISTANCE to golden for each side (measurement only).
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
SRC=${1:?src}; VIEW=${2:-plain}; ROOT=${3:-/tmp/v99_wd}
PRIS=${PRIS:?set PRIS}; CAND=${CAND:?set CAND}
B=$(basename "$SRC"); B=${B%.*}
SUE=""; SLE=""
[ "$VIEW" = elab ] && { SUE="-elabuhdm"; SLE="--elabuhdm"; }
D=$ROOT/${B}_$VIEW
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
S=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse $SUE -nocache -mt 0 -mp 0 "$S" > surelog.log 2>&1
if [ ! -f slpp_all/surelog.uhdm ]; then echo "$B $VIEW SURELOG_FAIL"; exit 5; fi
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
for side in P C; do
  BIN=$PRIS; [ $side = C ] && BIN=$CAND
  SLANG_UHDM=$BIN "$BIN" $SLE --single-unit "$S" -o out_$side.uhdm > slang_$side.log 2>&1
  echo "rc_$side=$?" >> rcs.txt
  if [ -f out_$side.uhdm ]; then
    "$DUMP" out_$side.uhdm 2>/dev/null | sed '1d' | sed "s#$D##g" > o_$side.dump
    "$CMP" slpp_all/surelog.uhdm out_$side.uhdm > cmp_$side.log 2>&1
    echo "cmp_$side=$?" >> rcs.txt
  else
    : > o_$side.dump; : > cmp_$side.log
  fi
done
HP=$(grep -c '^LHS:' cmp_P.log 2>/dev/null || echo 0)
HC=$(grep -c '^LHS:' cmp_C.log 2>/dev/null || echo 0)
LP=$(wc -l < cmp_P.log); LC=$(wc -l < cmp_C.log)
if cmp -s o_P.dump o_C.dump; then PC=IDENTICAL; else PC="MOVED:$(diff o_P.dump o_C.dump | grep -cE '^[<>]')"; fi
DP=$(diff <(sort g.dump) <(sort o_P.dump) | grep -cE '^[<>]' || true)
DC=$(diff <(sort g.dump) <(sort o_C.dump) | grep -cE '^[<>]' || true)
echo "$B $VIEW pris_vs_cand=$PC heads P=$HP/$LP C=$HC/$LC golden_dist P=$DP C=$DC WD=$D"
