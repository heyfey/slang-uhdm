#!/bin/bash
# v11u255 sweeps.sh <pristine worktree> <law worktree>: the four gate stages with $B/pristine and $B/law, one sweep
# at a time (tests/sweep.sh --jobs 3; workdirs $S/wP and $S/wL, same length), then the pristine probe stage rerun
# from the law worktree ($S/wQ) so the probe databases carry the same case paths. The harness dispatches every row.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
for t in P L; do wt=$1; b=$B/pristine; [ $t = L ] && { wt=$2; b=$B/law; }
  (cd $wt && SLANG_UHDM=$b bash tests/sweep.sh --jobs 3 --workdir $S/w$t --corpus "probe surelog uhdm2rtlil") > $S/sweep_$t.log 2>&1; echo "rc=$?" >> $S/sweep_$t.log; done
for t in P L; do wt=$1; b=$B/pristine; [ $t = L ] && { wt=$2; b=$B/law; }
  (cd $wt && SLANG_UHDM=$b bash tests/sweep.sh --jobs 3 --workdir $S/w$t --corpus downstream) > $S/ds_$t.log 2>&1; echo "rc=$?" >> $S/ds_$t.log; done
(cd $2 && SLANG_UHDM=$B/pristine python3 scripts/check_probe.py --jobs 3 --workdir $S/wQ/probe --out $S/wQ/probe.csv) > $S/probeQ.log 2>&1
