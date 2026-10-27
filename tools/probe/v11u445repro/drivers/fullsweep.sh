#!/bin/bash
# usage: fullsweep.sh <binary> <workdir> <tracedir> ; waits for three quiet readings (no sweep, runner or
# other agent's stage), then runs the four corpus stages from the worktree and the sv-tests stage via svstage.py
B=$1; WD=$2; TR=$3; [ -x "$B" ] || { echo "missing $B"; exit 2; }
source /tmp/wt_v11u445/tools/probe/r11u445repro/drivers/env.sh || exit 2
q=0; n=0
while [ $q -lt 3 ]; do
  c=$(pgrep -f 'tests/sweep.sh|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests|svtests_matrix' | grep -vw $$ | wc -l)
  if [ "$c" = 0 ]; then q=$((q+1)); else q=0; fi
  sleep 60; n=$((n+1))
done
echo "quiet after ${n} min: $(date)"
rm -rf $WD $TR; mkdir -p $TR
cd /tmp/wt_v11u445 && export SLANG_UHDM=$B R11U445_TRACE=$TR SVTESTS_ROOT=/nonexistent
tests/sweep.sh --jobs 3 --workdir $WD; echo "corpus-rc=$?"
python3 /tmp/wt_v11u445/tools/probe/v11u445repro/drivers/svstage.py $WD; echo "svtests-rc=$?"
date
