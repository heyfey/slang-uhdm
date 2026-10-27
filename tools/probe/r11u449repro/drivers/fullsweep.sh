#!/bin/bash
# fullsweep.sh: the one five-stage sweep on the final law binary (law5), trace on.
# The four corpus stages run from the worktree; the sv-tests stage runs through the
# main tree's check_svtests.py (the worktree's UVM submodule is empty) against the
# worktree's results/golden_svtests.csv, on the same binary.
source /tmp/r11u449_env.sh || exit 1
export SLANG_UHDM=/tmp/r11u449_bin/law5 R11U449_TRACE=/tmp/r11u449_sw_tr
[ -x "$SLANG_UHDM" ] || exit 1
mkdir -p $R11U449_TRACE
cd /tmp/wt_r11u449 && bash tests/sweep.sh --jobs 3 --workdir /tmp/r11u449_sw --corpus "probe surelog uhdm2rtlil downstream"
echo "CORPUS_DONE rc=$?"
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u449_sw/svtests \
   --out /tmp/r11u449_sw/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u449/results/golden_svtests.csv
echo "SVTESTS_DONE rc=$?"
