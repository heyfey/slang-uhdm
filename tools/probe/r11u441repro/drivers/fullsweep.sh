#!/bin/bash
# usage: fullsweep.sh <binary> <workdir (15 chars, the control's length)> <trace dir>
# step 0: traced runner call on the candidate sv-tests rows; then the five stages
# (four through the worktree's tests/sweep.sh, sv-tests through the main tree's
# scripts/check_svtests.py with the worktree's baseline, since the worktree's
# UVM submodule is empty)
source /tmp/r11u441_env.sh || exit 2
B=$1; W=$2; T=$3
[ -x "$B" ] || { echo "missing $B"; exit 2; }
export SLANG_UHDM=$B R11U441_TRACE=$T
mkdir -p $T $W
date; echo "binary $(md5sum < $B)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/r11u441_cand_law.csv --workroot /tmp/r11u441_rt_cand --jobs 3 --paths-file /tmp/r11u441_cand.list --keep-golden --uvm-dir third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > /tmp/r11u441_cand.log 2>&1
echo "candidates rc=$?"; date
cd /tmp/wt_r11u441
bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.corpus.log 2>&1
echo "corpus rc=$?"; date
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u441/results/golden_svtests.csv > $W.svtests.log 2>&1
echo "svtests rc=$?"; date
