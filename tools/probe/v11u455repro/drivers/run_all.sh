#!/bin/bash
# usage: run_all.sh <binary> <workdir>
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=$1; W=$2; unset GOLDEN_DEFER
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 2; }; done
q=0
while [ $q -lt 3 ]; do
  if pgrep -af 'tests/sweep.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests' | grep -v pgrep >/dev/null; then q=0; else q=$((q+1)); fi
  sleep 60
done
echo "quiet at $(date)" > $W.log
cd /tmp/wt_v11u455 || exit 1
bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.corpora.log 2>&1; echo "corpora rc=$?" >> $W.corpora.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests > $W.svtests.log 2>&1; echo "svtests rc=$?" >> $W.svtests.log
echo "done at $(date)" >> $W.log
