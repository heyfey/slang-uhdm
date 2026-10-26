#!/bin/bash
# r11u433 fullsweep.sh <binary> <workdir> <tracedir>: the one five-stage sweep (four corpus stages from the
# worktree, the sv-tests stage through the main tree's scripts/check_svtests.py: a worktree has no UVM tree)
B=$1; W=$2; T=$3
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$B R11U433_TRACE=$T
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 2; }; done
quiet() { [ -z "$(pgrep -f '[t]ests/sweep.sh|[s]vtests_matrix|[c]heck_probe.py|[v]erify_golden.py|[d]ownstream_uhdm2rtlil.py|[c]heck_svtests.py' | grep -v "^$$\$")" ]; }
n=0; while [ $n -lt 3 ]; do if quiet; then n=$((n+1)); echo "quiet reading $n $(date +%T)"; else n=0; echo "busy $(date +%T)"; fi; sleep 30; done
mkdir -p $W $T
cd /tmp/wt_r11u433 && bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream"; echo "corpus stages rc=$?"
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u433/results/golden_svtests.csv; echo "svtests stage rc=$?"
echo SWEEPDONE
