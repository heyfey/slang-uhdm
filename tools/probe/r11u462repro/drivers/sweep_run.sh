#!/bin/bash
# the one five-stage sweep on the final law binary, trace on
source /tmp/r11u462_env.sh || exit 1
export SLANG_UHDM=/tmp/r11u462_law8.bin
[ -x "$SLANG_UHDM" ] || exit 1
export R11U462_TRACE=/tmp/r11u462_trace
mkdir -p $R11U462_TRACE
W=/tmp/r11u462_wd
/tmp/r11u462_scr/quiet.sh > /tmp/r11u462_scr/quiet_before.txt
date > /tmp/r11u462_scr/sweep_times.txt
cd /tmp/wt_r11u462 && tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > /tmp/r11u462_scr/sweep_corpus.log 2>&1
echo "corpus rc=$?" >> /tmp/r11u462_scr/sweep_times.txt; date >> /tmp/r11u462_scr/sweep_times.txt
cd /home/heyfey/git-repos/slang-uhdm && tests/sweep.sh --jobs 3 --workdir $W --corpus svtests > /tmp/r11u462_scr/sweep_svtests.log 2>&1
echo "svtests rc=$?" >> /tmp/r11u462_scr/sweep_times.txt; date >> /tmp/r11u462_scr/sweep_times.txt
