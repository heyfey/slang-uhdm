#!/usr/bin/env bash
source /tmp/v11u131_drv/env.sh
unset GOLDEN_DEFER
cd /tmp/wt_v11u131 && SLANG_UHDM=/tmp/v11u131_bin/fix1 tests/sweep.sh --jobs 3 --workdir /tmp/v11u131_wdF --corpus "probe surelog uhdm2rtlil" > /tmp/v11u131_sweepF.log 2>&1; echo "F rc=$?" >> /tmp/v11u131_sweeps_done.txt
cd /tmp/wt_v11u131 && SLANG_UHDM=/tmp/v11u131_bin/fix1 tests/sweep.sh --jobs 3 --workdir /tmp/v11u131_wdG --corpus downstream > /tmp/v11u131_sweepG.log 2>&1; echo "G rc=$?" >> /tmp/v11u131_sweeps_done.txt
