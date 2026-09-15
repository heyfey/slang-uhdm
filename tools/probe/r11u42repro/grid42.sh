#!/usr/bin/env bash
# r11u42 GOLDEN GRID runner — MEASUREMENT ONLY.
#
#   usage: OURS=<frozen binary> WD=<scratch dir> ./grid42.sh [arm ...]
#
# Runs the pinned Surelog (the canonical golden producer) and the given
# slang-uhdm binary over each arm, records EVERY rc, dumps both databases and
# prints the hier_path VpiName of every path in SOURCE-LINE order, golden beside
# ours.  Nothing outside $WD is written; no corpus test is dispatched, so the
# four slang-fenced tests cannot be reached from here.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
OURS=${OURS:?set OURS to the frozen binary under test}
WD=${WD:-/tmp/r11u42_gridwd}
HERE=$(cd "$(dirname "$0")" && pwd)
ARMS=${*:-"g1 g2"}
mkdir -p "$WD"
names() {  # hier_path VpiName per source line, deduped, line-ordered
  grep -o 'hier_path: ([^)]*), line:[0-9]*:[0-9]*' "$1" \
   | sed -E 's/hier_path: \((.*)\), line:([0-9]+):([0-9]+)/\2.\3\t\1/' \
   | sort -u | sort -t. -k1,1n -k2,2n
}
for A in $ARMS; do
  SRC=$HERE/grid42/$A/dut.sv
  [ -f "$SRC" ] || { echo "ARM=$A MISSING_SOURCE"; continue; }
  mkdir -p "$WD/$A"
  "$SL" -parse -nobuiltin -nocache -sv "$SRC" -mt 0 -mp 0 -o "$WD/$A/g" \
      > "$WD/$A/surelog.log" 2>&1; echo "ARM=$A SURELOG_RC=$?"
  "$OURS" "$SRC" --single-unit -o "$WD/$A/o.uhdm" \
      > "$WD/$A/ours.log" 2>&1; echo "ARM=$A OURS_RC=$?"
  G="$WD/$A/g/slpp_all/surelog.uhdm"
  [ -f "$G" ] || { echo "ARM=$A GOLDEN_MISSING — this arm TEACHES NOTHING"; continue; }
  [ -f "$WD/$A/o.uhdm" ] || { echo "ARM=$A OURS_MISSING — compile failed, ERROR RECOVERY not golden"; continue; }
  "$DUMP" "$G" | tail -n +2 > "$WD/$A/golden.dump"; echo "ARM=$A GOLDEN_DUMP_RC=$?"
  "$DUMP" "$WD/$A/o.uhdm" | tail -n +2 > "$WD/$A/ours.dump"; echo "ARM=$A OURS_DUMP_RC=$?"
  echo "----- ARM $A  (LHS is ALWAYS golden)"
  paste <(names "$WD/$A/golden.dump") <(names "$WD/$A/ours.dump") \
   | awk -F'\t' '{s=($2==$4)?"SAME":"DIFF"; printf "%-9s GOLD %-34s | OURS %-34s %s\n",$1,$2,$4,s; if(s=="SAME")y++; else n++}
                 END{printf "ARM SUMMARY  SAME=%d DIFF=%d\n", y+0, n+0}'
done
