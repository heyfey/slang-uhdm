#!/usr/bin/env bash
# independent scoring: golden range-line agreement, using the repro's ranges.py
# with a PERMISSIVE member pattern (every member, not just a/b/v/wn/lpm).
set -u
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
R=${RANGES:-$(cd "$(dirname "$0")/../r10rgg3repro" && pwd)/ranges.py}
here=$(cd "$(dirname "$0")" && pwd)
printf "%-32s %-6s %-10s %-10s %s\n" CELL GLINES BASE PAT DELTA
for c in "$@"; do
  cd "$here/$c"
  # self-contained: take the golden here if run.sh has not already
  [ -s slpp_all/surelog.uhdm ] || \
    "$SL" -parse -nopython -d uhdm -top top dut.sv > gold.log 2> gold.err
  # GUARD: a cell whose GOLDEN side produced nothing is never scored
  [ -s slpp_all/surelog.uhdm ] || { printf "%-32s NO-GOLDEN\n" "$c"; continue; }
  $DUMP slpp_all/surelog.uhdm > g.dump 2>&1
  python3 $R g.dump '.' > g.rng 2>/dev/null
  n=$(wc -l < g.rng); [ "$n" -eq 0 ] && { printf "%-32s ZERO-GOLDEN-LINES\n" "$c"; continue; }
  out=""
  declare -A M
  for t in b p; do
    if [ -s ours_$t.uhdm ]; then
      $DUMP ours_$t.uhdm > o_$t.dump 2>&1
      python3 $R o_$t.dump '.' > o_$t.rng 2>/dev/null
      M[$t]=$(comm -12 <(sort g.rng) <(sort o_$t.rng) | wc -l)
    else M[$t]=-1; fi
  done
  d=$(( ${M[p]} - ${M[b]} ))
  tag=""; [ $d -gt 0 ] && tag="BETTER"; [ $d -lt 0 ] && tag="*** WORSE ***"
  printf "%-32s %-6s %-10s %-10s %s\n" "$c" "$n" "${M[b]}/$n" "${M[p]}/$n" "$d $tag"
done
