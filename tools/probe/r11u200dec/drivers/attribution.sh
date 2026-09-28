#!/bin/bash
# r11u200: each patch alone (lawA = law_exprstmt.patch, lawB = law_typeemit.patch): the probe stage in full and the
# corpus stages filtered to the row-modes the firing census names (none fenced: the census ran with the fence filter).
# usage: attribution.sh <binary tag> <workdir> <filter file>
set -u; HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3; REPO=$(cd "$HERE/../../../.." && pwd)
b=$1; W=$2; FIL=$(cat $3); mkdir -p $W; export SLANG_UHDM=$B/$b
for f in $FENCED; do grep -qw "$f" $3 && { echo "fenced name in filter"; exit 3; }; done
cd $REPO
python3 scripts/check_probe.py --jobs 2 --out $W/probe.csv --workdir $W/probe > $W/probe.log 2>&1
python3 scripts/compare_results.py $W/probe.csv results/golden_probe.csv > $W/probe.cmp 2>&1
for c in surelog uhdm2rtlil; do
  python3 scripts/verify_golden.py --corpus $c --mode both --jobs 2 --filter "$FIL" --out $W/$c.csv --workdir $W/$c > $W/$c.log 2>&1
  python3 scripts/compare_results.py $W/$c.csv results/golden_$c.csv --filter "$FIL" > $W/$c.cmp 2>&1
done
echo ATTR_DONE
