#!/usr/bin/env bash
# r10uvm115repro/fence115.sh — THE FENCE / THE PREDICTION, written from
# PRISTINE databases only.  MEASUREMENT ONLY; the official uhdm-cmp and
# scripts/verify_golden.py are the judges.  LHS is ALWAYS golden (Surelog);
# RHS is ALWAYS ours.
#
#   fence115.sh <verify_golden workdir> <cen binary> <out.tsv>
#
# For EVERY test directory in the workdir it censuses BOTH sides with ct115cen
# and runs fence115.py, which prints every DECLARATION cell in the builtin-class
# family (`process` / `semaphore` / `mailbox` / `std::…`) whose payload differs.
#
# GUARDS (each an ops trap this campaign has paid for): uhdm-cmp and `cen` EXIT
# 0 ON A MISSING INPUT, so both sides are existence-checked and a missing side
# is printed as SKIP and COUNTED; the golden path is read out of the test's own
# cmds.txt and the cache DIRECTORY is turned into .../golden.uhdm (handing a
# directory to a reader compares nothing); every cell records its own rc.
set -u
WD=${1:?workdir}; CEN=${2:?cen binary}; OUT=${3:?out tsv}
HERE=$(cd "$(dirname "$0")" && pwd)
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no cen at $CEN"; exit 3; }
T=$(mktemp -d /tmp/r10uvm115_fence.XXXXXX)
: > "$OUT"
n=0; skip=0
for d in "$WD"/*/*/; do
  [ -f "$d/cmds.txt" ] || continue
  mode=$(basename "$(dirname "$d")"); test=$(basename "$d")
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  O=$d/slang.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo -e "SKIP\t$mode\t$test" >> "$OUT"; skip=$((skip+1)); continue
  fi
  "$CEN" "$G" G > "$T/g.tsv" 2>/dev/null; rg=$?
  "$CEN" "$O" O > "$T/o.tsv" 2>/dev/null; ro=$?
  if [ $rg -ne 0 ] || [ $ro -ne 0 ]; then
    echo -e "CENFAIL\t$mode\t$test\trc=$rg/$ro" >> "$OUT"; skip=$((skip+1)); continue
  fi
  python3 "$HERE/fence115.py" "$T/g.tsv" "$T/o.tsv" "$mode" "$test" >> "$OUT"
  n=$((n+1))
done
rm -rf "$T"
echo "-- measured=$n SKIP=$skip"
for c in FAMILY MIRROR OTHERDIF; do
  echo "-- $c cells: $(grep -c "^$c" "$OUT" || true) in $(awk -F'\t' -v c=$c '$1==c{print $2"/"$3}' "$OUT" | sort -u | wc -l) databases"
done
echo "-- databases that MUST move:"
awk -F'\t' '$1=="FAMILY"{print $2"/"$3}' "$OUT" | sort -u
