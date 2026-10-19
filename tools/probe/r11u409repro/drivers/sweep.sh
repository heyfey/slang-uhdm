#!/bin/bash
# r11u409 law sweep: the four corpus stages from the worktree, then the sv-tests stage
# through the main tree's check_svtests.py (read-only; a worktree has no UVM tree)
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=/tmp/r11u409_bin/law.bin
export R11U409_TRACE=/tmp/r11u409_trace
export SVTESTS_ROOT=/nonexistent
rm -rf /tmp/r11u409_trace; mkdir -p /tmp/r11u409_trace
cd /tmp/wt_r11u409
bash tests/sweep.sh --jobs 3 --workdir /tmp/r11u409_wd --corpus "probe surelog uhdm2rtlil downstream" > /tmp/r11u409_wd_corpus.log 2>&1
echo "corpus rc=$?" >> /tmp/r11u409_wd_corpus.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u409_wd/svtests --out /tmp/r11u409_wd/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u409/results/golden_svtests.csv > /tmp/r11u409_wd_svtests.log 2>&1
echo "svtests rc=$?" >> /tmp/r11u409_wd_svtests.log
