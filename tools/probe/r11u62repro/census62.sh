#!/usr/bin/env bash
# r11u62 — the corpus-side keyed constant census over a NAMED candidate set.
#
#   usage: census62.sh <mode> <lawWorkdir> <prisWorkdir> <namefile> <outdir>
#
# For every named test that exists in BOTH workdirs it runs, in this order:
#   1. CALIBRATION golden-vs-golden (must print LINES 0 — a nonzero line there
#      voids every reading below it for that test),
#   2. golden-vs-PRISTINE,
#   3. golden-vs-LAW,
# and prints the pair (pristine lines, law lines).  A test whose two readings
# are equal did not move under the law; a test whose law reading is LOWER moved
# TOWARD golden by that many keyed shape rows; HIGHER is an AWAY-GOLDEN move
# and is called out by name.
set -u
MODE=${1:?mode}
LAW=${2:?law workdir}
PRIS=${3:?pristine workdir}
NAMES=${4:?name file}
OUT=${5:?outdir}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT" || exit 1
printf "%-40s %8s %8s %8s %s\n" TEST CALIB PRISTINE LAW VERDICT
tot=0; moved=0; away=0; skipped=0
while read -r n; do
  [ -n "$n" ] || continue
  d=$(ls -d "$LAW/$MODE/$n"-*/ 2>/dev/null | head -1)
  e=$(ls -d "$PRIS/$MODE/$n"-*/ 2>/dev/null | head -1)
  if [ -z "$d" ] || [ -z "$e" ] || [ ! -f "$d/slang.uhdm" ] || [ ! -f "$e/slang.uhdm" ]; then
    printf "%-40s %8s %8s %8s %s\n" "$n" - - - SKIP-NOFILE
    skipped=$((skipped+1)); continue
  fi
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  if [ -z "$G" ] || [ ! -f "$G/golden.uhdm" ]; then
    printf "%-40s %8s %8s %8s %s\n" "$n" - - - SKIP-NOGOLDEN
    skipped=$((skipped+1)); continue
  fi
  "$DUMP" "$G/golden.uhdm" > "$OUT/$n.$MODE.g.raw" 2>&1
  "$DUMP" "$e/slang.uhdm"  > "$OUT/$n.$MODE.p.raw" 2>&1
  "$DUMP" "$d/slang.uhdm"  > "$OUT/$n.$MODE.l.raw" 2>&1
  cal=$(python3 "$HERE/shape62.py" "$OUT/$n.$MODE.g.raw" "$OUT/$n.$MODE.g.raw" CAL | sed -n 's/.*LINES \([0-9]*\).*/\1/p')
  pl=$(python3 "$HERE/shape62.py" "$OUT/$n.$MODE.g.raw" "$OUT/$n.$MODE.p.raw" P | tee "$OUT/$n.$MODE.p.cen" | sed -n 's/.*LINES \([0-9]*\).*/\1/p')
  ll=$(python3 "$HERE/shape62.py" "$OUT/$n.$MODE.g.raw" "$OUT/$n.$MODE.l.raw" L | tee "$OUT/$n.$MODE.l.cen" | sed -n 's/.*LINES \([0-9]*\).*/\1/p')
  tot=$((tot+1))
  v=unchanged
  if [ "$cal" != "0" ]; then v=CALIB-NONZERO;
  elif [ "$ll" -lt "$pl" ]; then v="TO-GOLDEN(-$((pl-ll)))"; moved=$((moved+1));
  elif [ "$ll" -gt "$pl" ]; then v="AWAY-GOLDEN(+$((ll-pl)))"; away=$((away+1)); fi
  printf "%-40s %8s %8s %8s %s\n" "$n" "$cal" "$pl" "$ll" "$v"
done < "$NAMES"
echo "-- census62 mode=$MODE scored=$tot TO-GOLDEN=$moved AWAY-GOLDEN=$away skipped=$skipped"
