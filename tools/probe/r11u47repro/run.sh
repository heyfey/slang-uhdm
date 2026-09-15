#!/bin/bash
# r11u47 golden grid runner.  WD defaults to this script's own dir.
WD=${WD:-$(cd "$(dirname "${BASH_SOURCE[0]}")/arms" && pwd)}
BIN=${BIN:-/tmp/r11u47_bin/pris.bin}
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
OUT=${OUT:-/tmp/r11u47_grid/res_pris}
mkdir -p "$OUT"
LISTED=0; PROCESSED=0
exec 3< <(ls -d "$WD"/g*/ | sort -V)
while read -r d <&3; do
  LISTED=$((LISTED+1))
  g=$(basename "$d")
  w="$OUT/$g"; rm -rf "$w"; mkdir -p "$w"
  ( cd "$d" && "$SURELOG" -parse -sverilog -top dut dut.sv -mt 0 -mp 0 -o "$w/sl" ) </dev/null >"$w/surelog.log" 2>&1
  slrc=$?
  GU=$(ls "$w"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
  ( cd "$d" && "$BIN" dut.sv --single-unit -o "$w/ours.uhdm" ) </dev/null >"$w/slang.log" 2>&1
  ourc=$?
  if [ -n "$GU" ] && [ -f "$w/ours.uhdm" ]; then
    "$CMP" "$GU" "$w/ours.uhdm" >"$w/cmp.txt" 2>&1; cmprc=$?
    heads=$(grep -c '^LHS:' "$w/cmp.txt"; true)
    lines=$(wc -l < "$w/cmp.txt")
  else
    cmprc=NA; heads=NA; lines=NA
  fi
  echo "$g slrc=$slrc ourrc=$ourc cmprc=$cmprc heads=$heads cmplines=$lines golden=${GU:-NONE}"
  PROCESSED=$((PROCESSED+1))
done
exec 3<&-
echo "LISTED=$LISTED PROCESSED=$PROCESSED"
[ "$LISTED" = "$PROCESSED" ] || echo "GATE-FAIL listed!=processed"
