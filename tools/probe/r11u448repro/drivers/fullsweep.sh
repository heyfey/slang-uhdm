#!/bin/bash
# the one five-stage sweep on the final law binary: the four corpus stages from the worktree,
# then the svtests stage through the main tree's tests/sweep.sh (the worktree has no UVM submodule)
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=/tmp/r11u448_bin/law7 R11U448_TRACE=/tmp/r11u448_swtr
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do eval "[ -x \"\$$v\" ]" || { echo "missing $v"; exit 2; }; done
mkdir -p $R11U448_TRACE
echo "START $(date) live=$(pgrep -f 'tests/sweep.sh|svtests_matrix|check_svtests|verify_golden|check_probe|downstream_uhdm2rtlil' | wc -l)"
cd /tmp/wt_r11u448 && SVTESTS_ROOT=/nonexistent tests/sweep.sh --jobs 3 --workdir /tmp/r11u448_sw --corpus "probe surelog uhdm2rtlil downstream"
echo "CORPUS_DONE rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm && SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests tests/sweep.sh --jobs 3 --workdir /tmp/r11u448_sw --corpus svtests
echo "SVTESTS_DONE rc=$? $(date)"
