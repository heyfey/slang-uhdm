#!/bin/bash
# usage: v11u435_sweep.sh <binary> <workdir> <tracedir>
source /tmp/v11u435_env.sh
B=$1; W=$2; T=$3
[ -x "$B" ] || { echo "no binary"; exit 9; }
q=0
while [ $q -lt 3 ]; do
  if pgrep -f 'tests/sweep.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests' | grep -vw $$ >/dev/null; then q=0; else q=$((q+1)); fi
  sleep 20
done
echo "quiet at $(date)"
export SLANG_UHDM=$B R11U435_TRACE=$T
mkdir -p $T
cd /tmp/wt_v11u435
SVTESTS_ROOT=/nonexistent bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.sweep.log 2>&1
echo "four stages rc=$? at $(date)"
python3 tools/probe/v11u435repro/svstage.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests > $W.svtests.log 2>&1
echo "svtests rc=$? at $(date)"
