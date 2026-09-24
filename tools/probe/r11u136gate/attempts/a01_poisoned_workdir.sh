#!/bin/bash
# A1: a thread exception in verify_golden.py (a poisoned workdir: a regular file
# where the test's work dir goes). Usage: a01_poisoned_workdir.sh <repo> <workdir>
# Expected: the gate FAILS (the test's two rows were not measured).
set -u; R=$1; W=$2; T=1DUnpackedArray
rm -rf $W; mkdir -p $W/uhdm2rtlil/default
h=$(python3 -c "import hashlib,sys; print(hashlib.sha1(sys.argv[1].encode()).hexdigest()[:8])" "$UHDM2RTLIL_TESTS/$T")
echo poison > $W/uhdm2rtlil/default/$T-$h
echo "+ tests/sweep.sh --corpus uhdm2rtlil --filter '^$T\$' --workdir $W   (repo $R)"
$R/tests/sweep.sh --jobs 3 --corpus uhdm2rtlil --filter "^$T\$" --workdir $W; rc=$?
echo "+ fresh csv:"; cat $W/uhdm2rtlil.csv
echo "SWEEP rc=$rc"
