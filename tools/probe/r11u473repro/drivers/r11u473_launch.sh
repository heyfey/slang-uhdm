#!/bin/bash
# One five-stage sweep on the final law binary; four corpus stages from the worktree, sv-tests through the
# main tree's tests/sweep.sh (the worktree's UVM folder is empty).
source /tmp/r11u473_env.sh
export SLANG_UHDM=/tmp/r11u473_bin/law6 R11U473_TRACE=/tmp/r11u473_sw/trace
[ -x "$SLANG_UHDM" ] || exit 1
python3 /tmp/wt_r11u473/tools/probe/r11u473repro/drivers/r11u473_quiet.py 3600 > /tmp/r11u473_sw/quiet.log
cd /tmp/wt_r11u473 && echo "$(date) start corpus stages" >> /tmp/r11u473_sw/launch.txt
tests/sweep.sh --jobs 3 --workdir /tmp/r11u473_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/r11u473_sw/corpus.log 2>&1
echo "corpus rc=$?" >> /tmp/r11u473_sw/corpus.log
cd /home/heyfey/git-repos/slang-uhdm && echo "$(date) start svtests stage" >> /tmp/r11u473_sw/launch.txt
tests/sweep.sh --jobs 3 --workdir /tmp/r11u473_sw --corpus svtests > /tmp/r11u473_sw/svtests.log 2>&1
echo "svtests rc=$?" >> /tmp/r11u473_sw/svtests.log
echo "$(date) done" >> /tmp/r11u473_sw/launch.txt
