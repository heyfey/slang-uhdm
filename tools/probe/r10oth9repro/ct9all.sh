#!/usr/bin/env bash
# r10oth9 — run EVERY arm and print the CELL table for each, then the TOTALS.
#
#   usage: SLANG_UHDM=/path/to/slang-uhdm ./ct9all.sh <tag>
#
# <tag> names the scratch root, so a PRISTINE run and a PATCHED run never share a
# workdir.  That is the campaign's own rule (your own --workdir for every sweep)
# and it is enforced here rather than remembered.
#
# The four counters are kept SEPARATE on purpose and none of them subsumes
# another:
#   EQ           both sides emit the object and both fields agree
#   DIFFER       both sides emit the object, a FIELD disagrees (SIGNED/PARENT)
#   DIFFERKIND   both sides emit an object but of a DIFFERENT typespec CLASS —
#                not a field disagreement, and scoring it as EQ because the two
#                (absent) fields matched would be a FALSE agreement
#   UNMEASURED   one side emits NO object at all.  A louder reading than an
#                absent field, and never merged into DIFFER.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:?tag, e.g. pris or patched}
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
echo "BINARY: $SLANG_UHDM  md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1)"
tot=0; eq=0; df=0; kd=0; un=0
num() { echo "$1" | sed -E "s/.*$2=([0-9]+).*/\\1/"; }
for a in "$HERE"/b?_*.sv; do
  b=$(basename "$a"); n=${b%.*}
  d=/tmp/r10oth9_${TAG}_$n
  echo "================ ARM $n"
  "$HERE/ct9arm.sh" "$b" "$d" || { echo "ARM_FAILED $n"; continue; }
  out=$(python3 "$HERE/ct9cells.py" "$d/g.dump" "$d/o.dump")
  echo "$out"
  s=$(echo "$out" | tail -1)
  tot=$((tot + $(num "$s" CELLS)))
  eq=$((eq + $(num "$s" EQ)))
  df=$((df + $(num "$s" DIFFER)))
  kd=$((kd + $(num "$s" DIFFERKIND)))
  un=$((un + $(num "$s" 'UNMEASURED\(one side emits no object\)')))
done
echo "================ TOTALS across all arms"
echo "CELLS=$tot EQ=$eq DIFFER=$df DIFFERKIND=$kd UNMEASURED=$un"
