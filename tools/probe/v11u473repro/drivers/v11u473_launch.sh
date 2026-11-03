#!/bin/bash
# One five-stage sweep on the law binary (verifier); corpus stages from the worktree, sv-tests via the main tree.
source /tmp/v11u473_env.sh
export SLANG_UHDM=/tmp/v11u473_bin/law R11U473_TRACE=/tmp/v11u473_sw/trace
[ -x "$SLANG_UHDM" ] || exit 1
python3 /tmp/v11u473_drv/v11u473_quiet.py 14400 > /tmp/v11u473_sw/quiet.log
grep -q '^quiet' /tmp/v11u473_sw/quiet.log || exit 2
cd /tmp/wt_v11u473 && echo "$(date) start corpus stages" >> /tmp/v11u473_sw/launch.txt
tests/sweep.sh --jobs 3 --workdir /tmp/v11u473_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u473_sw/corpus.log 2>&1
echo "corpus rc=$?" >> /tmp/v11u473_sw/corpus.log
cd /home/heyfey/git-repos/slang-uhdm && echo "$(date) start svtests stage" >> /tmp/v11u473_sw/launch.txt
tests/sweep.sh --jobs 3 --workdir /tmp/v11u473_sw --corpus svtests > /tmp/v11u473_sw/svtests.log 2>&1
echo "svtests rc=$?" >> /tmp/v11u473_sw/svtests.log
echo "$(date) done" >> /tmp/v11u473_sw/launch.txt
