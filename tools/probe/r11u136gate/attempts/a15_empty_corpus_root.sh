#!/bin/bash
# A15: the corpus root points at an empty directory (a mis-set
# UHDM2RTLIL_TESTS, an uninitialised submodule): discovery finds 0 tests, the
# stage writes a header-only csv and the downstream stage 0 rows.
# Expected: the gate FAILS (1742 corpus rows and 871 downstream rows not run).
# Usage: <repo> <workdir>
set -u; R=$1; W=$2; rm -rf $W; mkdir -p $W/emptyroot
echo "+ UHDM2RTLIL_TESTS=<empty dir> tests/sweep.sh --corpus 'uhdm2rtlil downstream'   (repo $R)"
UHDM2RTLIL_TESTS=$W/emptyroot $R/tests/sweep.sh --jobs 3 --corpus "uhdm2rtlil downstream" --workdir $W 2>&1 | grep -v '^\(ONLY-COMMITTED\|REGRESSION ONLY-COMMITTED\|NOT_RUN\) [^.]'; rc=${PIPESTATUS[0]}
echo "SWEEP rc=$rc"
