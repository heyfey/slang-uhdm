#!/bin/bash
# v11u433 fullsweep.sh <binary> <workdir> <tracedir>
B=$1; W=$2; T=$3
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$B R11U433_TRACE=$T R11V433_TRACE=$T
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 2; }; done
quiet() { [ "$(ps -eo args | grep -E '^(/usr/bin/)?python3 [^ ]*(verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests|svtests_matrix)\.py|^(/bin/)?bash [^ ]*tests/sweep\.sh' | grep -v grep | wc -l)" = 0 ]; }
n=0; while [ $n -lt 3 ]; do if quiet; then n=$((n+1)); echo "quiet reading $n $(date +%T)"; else n=0; echo "busy $(date +%T)"; fi; sleep 30; done
mkdir -p $W $T; date
cd /tmp/wt_v11u433 && bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream"; echo "corpus stages rc=$?"; date
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u433/results/golden_svtests.csv; echo "svtests stage rc=$?"; date
echo SWEEPDONE
