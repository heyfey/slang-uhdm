#!/bin/bash
source /tmp/r11u420_env.sh
export SLANG_UHDM=/tmp/v11u420_bin/law R11U420_TRACE=/tmp/v11u420_trsw
mkdir -p /tmp/v11u420_trsw
cd /tmp/wt_v11u420
# wait for a quiet machine: three consecutive quiet readings
q=0; while [ $q -lt 3 ]; do
  if ps -eo args | grep -E 'sweep\.sh|svtests_matrix|check_svtests|verify_golden|check_probe|downstream_uhdm2rtlil' | grep -v grep | grep -v runsweep >/dev/null; then q=0; else q=$((q+1)); fi; sleep 20; done
date > /tmp/v11u420_sw.log
bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u420_sw --corpus "probe surelog uhdm2rtlil downstream" >> /tmp/v11u420_sw.log 2>&1
echo "corpus rc=$?" >> /tmp/v11u420_sw.log
date >> /tmp/v11u420_sw.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir /tmp/v11u420_sw/svtests --out /tmp/v11u420_sw/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u420/results/golden_svtests.csv > /tmp/v11u420_sw_svtests.log 2>&1
echo "svtests rc=$?" >> /tmp/v11u420_sw.log
date >> /tmp/v11u420_sw.log
