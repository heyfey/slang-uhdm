#!/bin/bash
source /tmp/v11u471_env.sh
export SLANG_UHDM=/tmp/v11u471_bin/law R11U471_TRACE=/tmp/v11u471_sw/trace
mkdir -p /tmp/v11u471_sw/trace
echo "$(date) start corpus stages SLANG_UHDM=$SLANG_UHDM md5=$(md5sum < $SLANG_UHDM)" >> /tmp/v11u471_sw/launch_log.txt
cd /tmp/wt_v11u471 && tests/sweep.sh --jobs 3 --workdir /tmp/v11u471_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u471_sw/corpus.log 2>&1
echo "corpus rc=$?" >> /tmp/v11u471_sw/corpus.log
echo "$(date) start svtests" >> /tmp/v11u471_sw/launch_log.txt
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/v11u471_sw/svtests --out /tmp/v11u471_sw/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/v11u471_golden_svtests_base.csv > /tmp/v11u471_sw/svtests.log 2>&1
echo "svtests rc=$?" >> /tmp/v11u471_sw/svtests.log
echo "$(date) done" >> /tmp/v11u471_sw/launch_log.txt
