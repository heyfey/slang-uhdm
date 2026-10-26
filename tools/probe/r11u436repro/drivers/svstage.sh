#!/bin/bash
# the sv-tests stage alone, through the main tree's scripts/check_svtests.py (a worktree has no UVM tree)
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump SLANG_UHDM=$1 R11U436_TRACE=$3
for v in "$SURELOG" "$UHDM_CMP" "$UHDM_DUMP" "$SLANG_UHDM"; do [ -x "$v" ] || { echo "missing $v"; exit 2; }; done
bash /tmp/wt_r11u436/tools/probe/r11u436repro/drivers/quiet.sh
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $2/svtests --out $2/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u436/results/golden_svtests.csv > $2/svtests.log 2>&1; echo "svtests stage rc=$?" >> $2/svtests.log
