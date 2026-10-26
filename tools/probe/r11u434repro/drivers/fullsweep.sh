#!/bin/bash
# r11u434 fullsweep.sh <binary> <workdir> <tracedir>: the one five-stage sweep (four corpus stages from the
# worktree, the sv-tests stage through the main tree's scripts/check_svtests.py: a worktree has no UVM tree),
# launched after three quiet readings 30 s apart.
B=$1; W=$2; T=$3
source /tmp/r11u434_env.sh
export SLANG_UHDM=$B R11U434_TRACE=$T
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 2; }; done
quiet() { ! pgrep -f '^(/usr/bin/)?(python3?|bash|/bin/bash|sh|/home/heyfey/.local/bin/python3) +([^ ]*/)?(tests/sweep\.sh|scripts/svtests/svtests_matrix\.py|scripts/verify_golden\.py|scripts/check_probe\.py|scripts/downstream_uhdm2rtlil\.py|scripts/check_svtests\.py)' >/dev/null; }
n=0; while [ $n -lt 3 ]; do if quiet; then n=$((n+1)); echo "quiet reading $n $(date +%T)"; else n=0; echo "busy $(date +%T)"; fi; sleep 30; done
mkdir -p $W $T
cd /tmp/wt_r11u434 && bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream"; echo "corpus stages rc=$?"
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u434/results/golden_svtests.csv; echo "svtests stage rc=$?"
echo SWEEPDONE
