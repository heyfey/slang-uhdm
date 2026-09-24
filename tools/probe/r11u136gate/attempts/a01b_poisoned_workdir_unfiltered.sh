#!/bin/bash
# A1b: the same poisoned test inside an UNFILTERED uhdm2rtlil corpus run.
# Usage: a01b_poisoned_workdir_unfiltered.sh <repo> <workdir>. Expected: FAIL.
set -u; R=$1; W=$2; T=1DUnpackedArray
rm -rf $W; mkdir -p $W/uhdm2rtlil/default
h=$(python3 -c "import hashlib,sys; print(hashlib.sha1(sys.argv[1].encode()).hexdigest()[:8])" "$UHDM2RTLIL_TESTS/$T")
echo poison > $W/uhdm2rtlil/default/$T-$h
echo "+ tests/sweep.sh --corpus uhdm2rtlil --workdir $W   (repo $R)"
$R/tests/sweep.sh --jobs 3 --corpus uhdm2rtlil --workdir $W | grep -v '^  [0-9]*/'; rc=${PIPESTATUS[0]}
echo "+ fresh csv rows of $T:"; grep "^$T," $W/uhdm2rtlil.csv
echo "SWEEP rc=$rc"
