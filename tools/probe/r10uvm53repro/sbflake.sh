#!/bin/bash
# r10uvm53repro/sbflake.sh — Scoreboard is BOTH a target row AND intermittently
# NONDETERMINISTIC (pass 41's recorded macro-buffer SourceLocation flake), so any
# byte or cmp question about it has to be settled by RE-RUNNING, not by one run.
# This runs the same test N times with one binary and prints the cmp LINE COUNT,
# HEAD COUNT and database sha256 each time.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#
#   usage: sbflake.sh <slang-binary> <N> <tag> [testname]
#
# GUARDS:
#   * uhdm-cmp EXITS 0 ON A MISSING INPUT: both sides are existence-checked and a
#     missing one prints NO_OUTPUT rather than a verdict;
#   * the golden path is read out of the run's own cmds.txt, so this cannot
#     silently compare against the wrong golden;
#   * a run that produced no database prints NO_DB and is counted, so a driver
#     that reaches nothing cannot read as "stable".
set -u
BIN=${1:?slang binary}
N=${2:?runs}
TAG=${3:?tag}
T=${4:-Scoreboard}
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE"/../../.. && pwd)
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$BIN" ] || { echo "FATAL: $BIN not executable"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: $CMP not executable"; exit 3; }
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)  test=$T runs=$N"
bad=0
for i in $(seq 1 "$N"); do
  WD=/tmp/${TAG}_sb_$i
  rm -rf "$WD"
  SLANG_UHDM=$BIN python3 "$ROOT/scripts/verify_golden.py" --corpus surelog \
    --mode default --jobs 1 --filter "^$T\$" --out "/tmp/${TAG}_sb_$i.csv" \
    --workdir "$WD" > "/tmp/${TAG}_sb_$i.log" 2>&1
  D=$(find "$WD" -name slang.uhdm -type f | head -1)
  if [ -z "$D" ]; then echo "  run $i NO_DB"; bad=$((bad+1)); continue; fi
  C=$(dirname "$D")/cmds.txt
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then echo "  run $i NO_OUTPUT(golden)"; bad=$((bad+1)); continue; fi
  "$CMP" "$G" "$D" > "/tmp/${TAG}_sb_$i.cmp" 2>&1
  printf '  run %d  cmplines=%s heads=%s sha256=%s\n' "$i" \
    "$(wc -l < "/tmp/${TAG}_sb_$i.cmp")" \
    "$(grep -c '^LHS:' "/tmp/${TAG}_sb_$i.cmp")" \
    "$(sha256sum "$D" | cut -c1-16)"
done
echo "---- runs with no measurement: $bad"
[ "$bad" -lt "$N" ] || { echo "REFUSING TO REPORT: measured nothing"; exit 5; }
