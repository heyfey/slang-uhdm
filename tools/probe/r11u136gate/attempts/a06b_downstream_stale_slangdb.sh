#!/bin/bash
# A6b: downstream_uhdm2rtlil.py's slang lane in a reused workdir: slang_db()
# did not remove <work>/<test>/slang.uhdm, so a slang-uhdm that writes nothing
# (SLANG_UHDM=/bin/false) is judged on the previous run's database.
# Expected: the verdict is SLANG_REJECT (not IDENTICAL), and since the row's
# baseline is IDENTICAL the gate FAILS. Usage: <repo> <workdir>
set -u; R=$1; W=$2; T=adff
rm -rf $W
echo "+ run 1: the binary under test"
$R/tests/sweep.sh --jobs 3 --corpus downstream --filter "^$T\$" --workdir $W | grep downstream:
echo "+ run 2: SLANG_UHDM=/bin/false, the same workdir"
SLANG_UHDM=/bin/false $R/tests/sweep.sh --jobs 3 --corpus downstream --filter "^$T\$" --workdir $W; rc=$?
cat $W/downstream.csv
echo "SWEEP rc=$rc"
