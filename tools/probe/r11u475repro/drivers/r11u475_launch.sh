#!/bin/bash
# one five-stage sweep on law8: four stages from the worktree, the sv-tests stage through the main tree
source /tmp/r11u475_env.sh
export SLANG_UHDM=/tmp/r11u475_bin/law8
export SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
export R11U475_TRACE=/tmp/r11u475_swtrace
[ -x "$SLANG_UHDM" ] || exit 9
mkdir -p /tmp/r11u475_swtrace
cd /tmp/wt_r11u475 && tests/sweep.sh --jobs 3 --workdir /tmp/r11u475_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/r11u475_scratch/sweep4.log 2>&1
echo "rc4=$?" >> /tmp/r11u475_scratch/sweep4.log
cd /home/heyfey/git-repos/slang-uhdm && tests/sweep.sh --jobs 3 --workdir /tmp/r11u475_sw --corpus svtests > /tmp/r11u475_scratch/sweepsv.log 2>&1
echo "rcsv=$?" >> /tmp/r11u475_scratch/sweepsv.log
