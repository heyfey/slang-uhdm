#!/bin/bash
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=/tmp/v11u472_bin/law
export R11U472_TRACE=/tmp/v11u472_trace
mkdir -p $R11U472_TRACE
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 1; }; done
cd /tmp/wt_v11u472 && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u472_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u472_scratch/sweep_a.log 2>&1; echo "rcA=$?" >> /tmp/v11u472_scratch/sweep_a.log
cd /home/heyfey/git-repos/slang-uhdm && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u472_sw --corpus svtests > /tmp/v11u472_scratch/sweep_b.log 2>&1; echo "rcB=$?" >> /tmp/v11u472_scratch/sweep_b.log
