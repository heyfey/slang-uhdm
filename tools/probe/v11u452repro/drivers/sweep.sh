#!/bin/bash
# sweep.sh <binary> <workdir(15 chars)> <tag>
B=$1; W=$2; t=$3
[ -x "$B" ] || exit 2
/tmp/wt_v11u452/tools/probe/v11u452repro/drivers/quiet.sh
source /tmp/v11u452_env.sh; export SLANG_UHDM=$B
rm -rf $W /tmp/v11u452_tr_$t; mkdir -p /tmp/v11u452_tr_$t
date > /tmp/v11u452_sweep_$t.start
cd /tmp/wt_v11u452 && R11U452_TRACE=/tmp/v11u452_tr_$t bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u452_sweep_$t.log 2>&1
echo rc=$? >> /tmp/v11u452_sweep_$t.log
/tmp/wt_v11u452/tools/probe/v11u452repro/drivers/quiet.sh
mkdir -p /tmp/v11u452_trsv_$t
cd /home/heyfey/git-repos/slang-uhdm && R11U452_TRACE=/tmp/v11u452_trsv_$t python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u452/results/golden_svtests.csv > /tmp/v11u452_sv_$t.log 2>&1
echo rc=$? >> /tmp/v11u452_sv_$t.log
date > /tmp/v11u452_sweep_$t.done
