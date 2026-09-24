#!/bin/bash
# A7d: the binary at UHDM_CMP is wrong (/bin/true) and a real judge-level
# regression happens: the flip's control b3' (v59v2_earl59's golden replaced by
# v59v1_earl59's, a STRICT_NOTEQUAL case that must read NOT_EQUAL). The strict
# comparator's own stage 1 is uhdm-cmp's Compare, so the gate must still FAIL.
# Usage: <repo> <workdir> <uhdm-cmp binary>
set -u; R=$1; W=$2; J=$3; G=$W.cache
rm -rf $W $G; mkdir -p $G
for c in a1_earl59 v59v1_earl59 v59v2_earl59 v59v3_earl59; do
  k=$(GOLDEN_CACHE=$G python3 -c "import os,sys; sys.path.insert(0,'$R/scripts'); import check_probe as c; print(os.path.basename(c.cache_dir('r10earl59repro/$c')))")
  cp -r $HOME/.cache/slang-uhdm-goldens/$k $G/$k; eval "k_$c=$k"
done
cp $G/$k_v59v1_earl59/golden.uhdm $G/$k_v59v2_earl59/golden.uhdm
echo "+ GOLDEN_CACHE=<private, v59v2's golden := v59v1's> UHDM_CMP=$J tests/sweep.sh --corpus probe --filter '^r10earl59repro/'   (repo $R)"
GOLDEN_CACHE=$G UHDM_CMP=$J $R/tests/sweep.sh --jobs 3 --corpus probe --filter '^r10earl59repro/' --workdir $W | grep -v '^ONLY-COMMITTED'; rc=${PIPESTATUS[0]}
cat $W/probe.csv
echo "SWEEP rc=$rc"
