#!/bin/bash
# A3: a probe case whose dut.sv is deleted (r10earl59repro/a1_earl59, EQUAL) and
# one whose dut.sv is renamed to dut.v (r10earl59repro/v59v2_earl59,
# STRICT_NOTEQUAL): check_probe.py globs **/dut.sv, so both cases vanish from
# the run. Expected: the gate FAILS. Usage: <repo> <scratch> [filter]
set -u; R=$1; D=$2; F=${3:-}
$(dirname $0)/mkfake.sh $R $D
rm $D/tests/probe/r10earl59repro/a1_earl59/dut.sv
mv $D/tests/probe/r10earl59repro/v59v2_earl59/dut.sv $D/tests/probe/r10earl59repro/v59v2_earl59/dut.v
echo "+ check_probe.py --out probe.csv ${F:+--filter $F}; compare_results.py probe.csv results/golden_probe.csv ${F:+--filter $F}   (scripts of $R)"
python3 $D/scripts/check_probe.py --jobs 3 --workdir $D.wd --out $D.csv ${F:+--filter "$F"}; echo "check_probe rc=$?"
python3 $D/scripts/compare_results.py $D.csv $D/results/golden_probe.csv ${F:+--filter "$F"} 2>&1 | grep -v '^\(ONLY-COMMITTED [^.]\)'; rc=${PIPESTATUS[0]}
# the base compare has no --filter: rerun without it for the record
echo "GATE rc=$rc"
