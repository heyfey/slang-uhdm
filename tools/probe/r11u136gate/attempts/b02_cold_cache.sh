#!/bin/bash
# B2: a cold golden cache (a private, empty GOLDEN_CACHE: every golden built by
# the producer now) must give the verdicts the warm cache gives. Subsets:
# uhdm2rtlil + downstream '^[a-c]', surelog '^(Assign|Bit|Case)'.
# Usage: <repo> <workdir>; then join each csv against the warm sweep's.
set -u; R=$1; W=$2; rm -rf $W $W.cache; mkdir -p $W.cache
GOLDEN_CACHE=$W.cache $R/tests/sweep.sh --jobs 3 --corpus "uhdm2rtlil downstream" --filter '^[a-c]' --workdir $W/u 2>&1 | grep -v '^  [0-9]*/'; echo "SWEEP u rc=${PIPESTATUS[0]}"
GOLDEN_CACHE=$W.cache $R/tests/sweep.sh --jobs 3 --corpus "surelog" --filter '^(Assign|Bit|Case)' --workdir $W/s 2>&1 | grep -v '^  [0-9]*/'; echo "SWEEP s rc=${PIPESTATUS[0]}"
