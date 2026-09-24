#!/bin/bash
# A6a: verify_golden.py's GOLDEN side in a reused workdir. With the cache off
# (GOLDEN_CACHE=0) Surelog writes <work>/slpp_all/surelog.uhdm; a second run
# whose Surelog writes nothing (SURELOG=/bin/false: a crash, an OOM) globs the
# first run's database and judges against it. Expected: SURELOG_FAIL -> the
# gate FAILS. Usage: a06a_stale_golden_workdir.sh <repo> <workdir>
set -u; R=$1; W=$2; T=1DUnpackedArray
rm -rf $W
echo "+ run 1: GOLDEN_CACHE=0, the pinned Surelog"
GOLDEN_CACHE=0 $R/tests/sweep.sh --jobs 3 --corpus uhdm2rtlil --filter "^$T\$" --workdir $W | grep 'regressions='
ls $W/uhdm2rtlil/*/$T-*/slpp_all/
echo "+ run 2: GOLDEN_CACHE=0 SURELOG=/bin/false, the same workdir"
GOLDEN_CACHE=0 SURELOG=/bin/false $R/tests/sweep.sh --jobs 3 --corpus uhdm2rtlil --filter "^$T\$" --workdir $W; rc=$?
cat $W/uhdm2rtlil.csv; cat $W/uhdm2rtlil/default/$T-*/cmds.txt
echo "SWEEP rc=$rc"
