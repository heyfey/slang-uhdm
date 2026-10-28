#!/bin/bash
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=/tmp/v11u453_bin/law
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 2; }; done
unset GOLDEN_DEFER
export R11U453_TRACE=/tmp/v11u453_trace
mkdir -p $R11U453_TRACE
cd /tmp/wt_v11u453 || exit 2
echo "start $(date)"
tests/sweep.sh --jobs 3 --workdir /tmp/v11u453swp --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm || exit 2
python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/v11u453swp/svtests --out /tmp/v11u453swp/svtests.csv --svtests /home/heyfey/git-repos/sv-tests
echo "svtests rc=$? $(date)"
