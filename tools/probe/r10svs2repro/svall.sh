#!/usr/bin/env bash
# r10svs2 — run EVERY arm and print the CELL table for each, then the TOTALS.
#
#   usage: SLANG_UHDM=/path/to/slang-uhdm ./svall.sh <tag>
#
# <tag> names the scratch root, so a PRISTINE run and a PATCHED run never share a
# workdir.  That is the campaign's own rule (your own --workdir for every sweep)
# and it is enforced here rather than remembered.
#
# The GOLDEN side is regenerated per run from the arm source in THIS directory,
# so an arm source edit can never be read against a stale golden dump -- that
# exact mistake produced a 14/14 UNMEASURED table during this pass and is the
# reason the golden refresh is inside the driver instead of alongside it.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:?tag, e.g. pris or patched}
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
echo "BINARY: $SLANG_UHDM  md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1)"
tot=0; eq=0; df=0; kd=0; un=0
num() { echo "$1" | sed -E "s/.*$2=([0-9]+).*/\\1/"; }
for a in "$HERE"/s?_*.sv; do
  b=$(basename "$a"); n=${b%.*}
  d=/tmp/r10svs2_${TAG}_$n
  echo "================ ARM $n"
  "$HERE/svarm.sh" "$b" "$d" || { echo "ARM_FAILED $n"; continue; }
  out=$(python3 "$HERE/svcells.py" "$d/g.dump" "$d/o.dump")
  echo "$out"
  s=$(echo "$out" | tail -1)
  tot=$((tot + $(num "$s" CELLS)))
  eq=$((eq + $(num "$s" EQ)))
  df=$((df + $(num "$s" DIFFER)))
  kd=$((kd + $(num "$s" DIFFERKIND)))
  un=$((un + $(num "$s" 'UNMEASURED\(one side emits no element\)')))
done
echo "================ TOTALS across all arms"
echo "CELLS=$tot EQ=$eq DIFFER=$df DIFFERKIND=$kd UNMEASURED=$un"
