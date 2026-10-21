#!/bin/bash
source /tmp/r11u424_scratch/env.sh
export SLANG_UHDM=/tmp/r11u424_bin/law21
export R11U424_TRACE=/tmp/r11u424_scratch/trace
mkdir -p $R11U424_TRACE
[ -x "$SLANG_UHDM" ] || exit 2
cd /tmp/wt_r11u424
echo "start $(date)"
tests/sweep.sh --jobs 3 --workdir /tmp/r11u424wd --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u424wd/svtests --out /tmp/r11u424wd/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u424/results/golden_svtests.csv
echo "svtests rc=$? $(date)"
