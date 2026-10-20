#!/bin/bash
# v11u415 sweep.sh <binary> <workdir>: four corpus stages from the worktree, then the sv-tests stage through the main tree's script (read-only)
B=$1; W=$2
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$B
wait_quiet() { while ps -eo args | grep -E 'sweep.sh|svtests_matrix|check_svtests|verify_golden|check_probe|downstream_uhdm2rtlil' | grep -v grep | grep -v "$W" | grep -q .; do sleep 30; done; }
wait_quiet
cd /tmp/wt_v11u415 && bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.corpus.log 2>&1; echo rc=$? >> $W.corpus.log
wait_quiet
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests > $W.svtests.log 2>&1; echo rc=$? >> $W.svtests.log
echo DONE >> $W.svtests.log
