#!/bin/bash
# A13: a failing stage followed by passing stages: SLANG_UHDM=/bin/false fails
# the probe stage; the downstream stage then runs (at the base it reads the
# rejection as the allowed SLANG_REJECT and passes). Expected: rc 1.
# Then a stale law index alone (--corpus ""): expected rc 1.
# Usage: <repo> <workdir>
set -u; R=$1; W=$2; rm -rf $W
F='^(r10earl59repro/.*|adff)$'
echo "+ SLANG_UHDM=/bin/false tests/sweep.sh --corpus 'probe downstream' --filter '$F'"
SLANG_UHDM=/bin/false $R/tests/sweep.sh --jobs 3 --corpus "probe downstream" --filter "$F" --workdir $W 2>&1 | grep -v '^\(ONLY-COMMITTED\|REGRESSION ONLY-COMMITTED\) [^.]'; echo "SWEEP rc=${PIPESTATUS[0]}"
echo "+ tests/sweep.sh --corpus '' (the law index alone, current)"
$R/tests/sweep.sh --corpus "" --workdir $W; echo "SWEEP rc=$?"
