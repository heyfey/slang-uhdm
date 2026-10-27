#!/bin/bash
# usage: fullsweep.sh <binary> <workdir (15 chars, the control's length)> <trace dir>
# four corpus stages through the worktree's tests/sweep.sh, the sv-tests stage
# through the main tree's scripts/check_svtests.py with the worktree's
# baseline (a worktree's UVM submodule is empty); waits for three quiet readings
source /tmp/r11u443_env.sh || exit 2
B=$1; W=$2; T=$3
[ -x "$B" ] || { echo "missing $B"; exit 2; }
export SLANG_UHDM=$B R11U443_TRACE=$T
mkdir -p $T $W
q=0
while [ $q -lt 3 ]; do
  if ps -eo pid=,args= | grep -E 'sweep\.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests' | grep -v -e grep -e r11u443 >/dev/null; then q=0; else q=$((q+1)); fi
  sleep 20
done
date; echo "binary $(md5sum < $B)"
cd /tmp/wt_r11u443
bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.corpus.log 2>&1
echo "corpus rc=$?"; date
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u443/results/golden_svtests.csv > $W.svtests.log 2>&1
echo "svtests rc=$?"; date
