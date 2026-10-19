#!/bin/bash
# v11u411 sweep.sh <binary> <workdir> <tracedir>: five stages once
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$1
WD=$2; export R11U411_TRACE=$3
rm -rf $WD $3; mkdir -p $WD $3
cd /tmp/wt_v11u411
date > $WD.times
bash tests/sweep.sh --jobs 3 --workdir $WD --corpus "probe surelog uhdm2rtlil downstream" > $WD.corpus.log 2>&1; echo "corpus rc=$?" >> $WD.corpus.log
date >> $WD.times
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $WD/svtests --out $WD/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u411/results/golden_svtests.csv > $WD.svtests.log 2>&1; echo "svtests rc=$?" >> $WD.svtests.log
date >> $WD.times
