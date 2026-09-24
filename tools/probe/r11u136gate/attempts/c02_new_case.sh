#!/bin/bash
# C2: a new case dir (absent from results/golden_probe.csv) must be EQUAL to
# pass. new_sne holds v59v2_earl59's text (STRICT_NOTEQUAL), new_eq holds
# v59v1_earl59's (EQUAL). Goldens are built by the pinned Surelog into a private
# cache. Expected: new_sne alone FAILS (REGRESSION ONLY-FRESH), new_eq alone
# passes (ONLY-FRESH). Usage: <repo> <scratch>
set -u; R=$1; D=$2; G=$D.cache
$(dirname $0)/mkfake.sh $R $D; rm -rf $G; mkdir -p $G
for p in sne:v59v2_earl59 eq:v59v1_earl59; do mkdir -p $D/tests/probe/r11u136gate/new_${p%%:*}; cp $R/tests/probe/r10earl59repro/${p#*:}/dut.sv $D/tests/probe/r11u136gate/new_${p%%:*}/; done
FA() { grep -q "add_argument('--filter'" $D/scripts/compare_results.py && echo "--filter $1"; }
for c in new_sne new_eq; do
  F="^r11u136gate/$c\$"
  echo "+ check_probe.py --filter '$F'; compare_results.py $(FA "$F")"
  GOLDEN_CACHE=$G python3 $D/scripts/check_probe.py --jobs 3 --workdir $D.wd --out $D.csv --filter "$F" | grep 'probe cases'
  python3 $D/scripts/compare_results.py $D.csv $D/results/golden_probe.csv $(FA "$F") | grep -v '^ONLY-COMMITTED'; echo "GATE $c rc=${PIPESTATUS[0]}"
done
