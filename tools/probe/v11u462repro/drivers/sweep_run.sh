#!/bin/bash
# the verifier's one five-stage sweep on the law binary (rebuilt from the patch), trace on
source /tmp/v11u462_env.sh || exit 1
export SLANG_UHDM=/tmp/v11u462_bin/law.bin
[ -x "$SLANG_UHDM" ] || exit 1
export R11U462_TRACE=/tmp/v11u462_trace
mkdir -p $R11U462_TRACE
W=/tmp/v11u462_wd
/tmp/v11u462_drv/quiet.sh > /tmp/v11u462_quiet_before.txt
date > /tmp/v11u462_sweep_times.txt
cd /tmp/wt_v11u462 && tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u462_sweep_corpus.log 2>&1
echo "corpus rc=$?" >> /tmp/v11u462_sweep_times.txt; date >> /tmp/v11u462_sweep_times.txt
cd /home/heyfey/git-repos/slang-uhdm && tests/sweep.sh --jobs 3 --workdir $W --corpus svtests > /tmp/v11u462_sweep_svtests.log 2>&1
echo "svtests rc=$?" >> /tmp/v11u462_sweep_times.txt; date >> /tmp/v11u462_sweep_times.txt
echo SWEEPDONE >> /tmp/v11u462_sweep_times.txt
