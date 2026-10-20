#!/bin/bash
# r11u413 sweep.sh <binary> <workdir> <tracedir>: the five stages once.
# The four corpus stages through the worktree's tests/sweep.sh; the sv-tests
# stage through the main tree's scripts/check_svtests.py read-only (a worktree
# has no UVM tree) with the worktree's baseline.
B=$1; W=$2; T=$3; WT=/tmp/wt_v11u413; MAIN=/home/heyfey/git-repos/slang-uhdm
export SURELOG_ROOT=$MAIN/third_party/Surelog UHDM2RTLIL_TESTS=$MAIN/third_party/uhdm2rtlil/test \
  SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog \
  UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp \
  UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump \
  UHDM2RTLIL_ROOT=$MAIN/third_party/uhdm2rtlil SLANG_UHDM=$B R11U413_TRACE=$T
mkdir -p $W $T
cd $WT && bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W/sweep_corpus.log 2>&1
echo "corpus rc=$?" >> $W/sweep_corpus.log
python3 $MAIN/scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv \
  --svtests /home/heyfey/git-repos/sv-tests --baseline $WT/results/golden_svtests.csv > $W/sweep_svtests.log 2>&1
echo "svtests rc=$?" >> $W/sweep_svtests.log
