#!/bin/bash
# A7: the comparator binary at STRICT_CMP is not the pinned one.
#   <cmp> = uhdm-cmp (a plausible mix-up: it prints its usage and exits 0 on
#           `--max 0 <a> <b>`), /bin/true, or an older uhdm-strictcmp build.
# With R11U124_OFF=1 (the flip's negative control b2: pass 124's laws off, a
# real regression of 180 probe cases to STRICT_NOTEQUAL) the gate must FAIL
# whatever binary sits at STRICT_CMP. Usage: <repo> <workdir> <cmp> [law-off: 1|0]
set -u; R=$1; W=$2; C=$3; OFF=${4:-1}
rm -rf $W
echo "+ STRICT_CMP=$C $([ $OFF = 1 ] && echo R11U124_OFF=1) tests/sweep.sh --corpus probe   (repo $R)"
if [ $OFF = 1 ]; then export R11U124_OFF=1; fi
STRICT_CMP=$C $R/tests/sweep.sh --jobs 3 --corpus probe --workdir $W | grep -v '^\(REGRESSION\|CONVERSION\|CHANGE\|ONLY\)' ; rc=${PIPESTATUS[0]}
grep -c '^REGRESSION' <(python3 $R/scripts/compare_results.py $W/probe.csv $R/results/golden_probe.csv) | sed 's/^/regression lines: /'
echo "SWEEP rc=$rc"
