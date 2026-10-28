#!/bin/bash
# usage: sweep.sh <binary> <workdir>
source /tmp/v11u454_s/env.sh || exit 1
export SLANG_UHDM=$1; W=$2
[ -x "$SLANG_UHDM" ] || { echo "no binary"; exit 1; }
unset GOLDEN_DEFER
cd /tmp/wt_v11u454 || exit 1
bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.corpora.log 2>&1; echo "corpora rc=$?" >> $W.corpora.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests > $W.svtests.log 2>&1; echo "svtests rc=$?" >> $W.svtests.log
echo SWEEPDONE
