#!/bin/bash
# runsweep.sh <bin> <workdir>: waits quiet, runs the four worktree stages, then the svtests stage via the main tree's checker
B=$1; WD=$2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
case "$WD" in /tmp/v11u484sw?) ;; *) echo "bad workdir $WD"; exit 1;; esac
source /tmp/v11u484_tools/env.sh || exit 1
export SLANG_UHDM=$B
python3 /tmp/v11u484_tools/quietwait.py
echo "start $(date) $B $(md5sum < $B)"
cd /tmp/wt_v11u484 && bash tests/sweep.sh --jobs 3 --workdir $WD; echo "sweep rc=$? $(date)"
python3 /tmp/v11u484_tools/quietwait.py
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $WD/svtests --out $WD/svtests.csv --svtests /home/heyfey/git-repos/sv-tests; echo "svtests rc=$? $(date)"
