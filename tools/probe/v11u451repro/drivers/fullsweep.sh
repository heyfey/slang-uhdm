#!/bin/bash
# fullsweep.sh <binary> <workdir> [trace dir]: the five stages once
source /tmp/v11u451_env.sh || exit 1
export SLANG_UHDM=$1; W=$2
[ -x "$SLANG_UHDM" ] || exit 1
[ -n "$3" ] && { export R11U451_TRACE=$3; mkdir -p $3; }
cd /tmp/wt_v11u451 && bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.log 2>&1
echo "CORPUS_DONE rc=$?" >> $W.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $W/svtests \
   --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u451/results/golden_svtests.csv >> $W.log 2>&1
echo "SVTESTS_DONE rc=$?" >> $W.log
