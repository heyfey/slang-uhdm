#!/bin/bash
# the sv-tests stage alone on the sweep's binary and workdir, through the main
# tree's check_svtests.py (the worktree's UVM submodule is empty) against the
# worktree's golden_svtests.csv
/tmp/wt_r11u450/tools/probe/r11u450repro/drivers/quiet.sh
source /tmp/r11u450_env.sh; export SLANG_UHDM=/tmp/r11u450_bin/law12
cd /home/heyfey/git-repos/slang-uhdm
date > /tmp/r11u450_sv.start
R11U450_TRACE=/tmp/r11u450_swtr python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u450swp/svtests --out /tmp/r11u450swp/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u450/results/golden_svtests.csv > /tmp/r11u450_sv.log 2>&1
echo rc=$? >> /tmp/r11u450_sv.log
date > /tmp/r11u450_sv.done
