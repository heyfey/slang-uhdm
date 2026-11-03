#!/bin/bash
# v11u468_sweep.sh <binary> <workdir> [trace dir]
B=$1; WD=$2; TR=$3
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$B
unset GOLDEN_DEFER
[ -n "$TR" ] && { mkdir -p $TR; export R11U468_TRACE=$TR; }
python3 /tmp/v11u468_quietwait.py
mkdir -p $WD; date > $WD/start.txt
cd /tmp/wt_v11u468 && bash tests/sweep.sh --jobs 3 --workdir $WD --corpus "probe surelog uhdm2rtlil downstream" > $WD/sweep4.log 2>&1; echo "sweep4 rc=$?" > $WD/rc.txt
python3 /tmp/v11u468_quietwait.py
cd /home/heyfey/git-repos/slang-uhdm && bash tests/sweep.sh --jobs 3 --workdir $WD --corpus svtests > $WD/sweepsv.log 2>&1; echo "sweepsv rc=$?" >> $WD/rc.txt
date > $WD/done.txt
