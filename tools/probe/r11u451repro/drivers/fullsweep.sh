#!/bin/bash
# fullsweep.sh: the one five-stage sweep on the final law binary (law7), trace on.
# The four corpus stages run from the worktree; the sv-tests stage runs through the
# main tree's check_svtests.py (the worktree's UVM submodule is empty) against the
# worktree's results/golden_svtests.csv, on the same binary.
source /tmp/r11u451_env.sh || exit 1
export SLANG_UHDM=/tmp/r11u451_bin/law7 R11U451_TRACE=/tmp/r11u451_sw_tr
[ -x "$SLANG_UHDM" ] || exit 1
mkdir -p $R11U451_TRACE
cd /tmp/wt_r11u451 && bash tests/sweep.sh --jobs 3 --workdir /tmp/r11u451_sw --corpus "probe surelog uhdm2rtlil downstream"
echo "CORPUS_DONE rc=$?"
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u451_sw/svtests \
   --out /tmp/r11u451_sw/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u451/results/golden_svtests.csv
echo "SVTESTS_DONE rc=$?"
