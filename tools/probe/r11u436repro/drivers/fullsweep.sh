#!/bin/bash
# usage: fullsweep.sh <binary> <workdir> <tracedir>; the sv-tests stage of a worktree sweep reads the worktree's empty UVM tree, so that stage is rerun alone through svstage.sh
# the one full five-stage sweep on the final law binary, with the trace on
cd /tmp/wt_r11u436 || exit 1
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$1 SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
for v in "$SURELOG" "$UHDM_CMP" "$UHDM_DUMP" "$SLANG_UHDM"; do [ -x "$v" ] || { echo "missing $v"; exit 2; }; done
export R11U436_TRACE=$3; mkdir -p $3
bash /tmp/wt_r11u436/tools/probe/r11u436repro/drivers/quiet.sh
date; tests/sweep.sh --jobs 3 --workdir $2 > $2.log 2>&1; echo "sweep rc=$?" >> $2.log; date
