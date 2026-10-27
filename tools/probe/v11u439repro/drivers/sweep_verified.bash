#!/bin/bash
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=/tmp/v11u439_bin/verified
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 2; }; done
export R11U439_TRACE=/tmp/v11u439_trace2; mkdir -p $R11U439_TRACE
WD=/tmp/v11u439_VF
P1='sweep\.s''h|svtests_matr''ix|verify_gold''en|check_pro''be|downstream_uhdm2rt''lil|check_svte''sts'
n=0; while [ $n -lt 3 ]; do if pgrep -f "$P1" >/dev/null; then n=0; else n=$((n+1)); fi; sleep 60; done
echo "start $(date +%T)"
cd /tmp/wt_v11u439 && bash tests/sweep.sh --jobs 3 --workdir $WD --corpus 'probe surelog uhdm2rtlil downstream'; echo "corpora rc=$? $(date +%T)"
n=0; while [ $n -lt 3 ]; do if pgrep -f "$P1" >/dev/null; then n=0; else n=$((n+1)); fi; sleep 60; done
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $WD/svtests --out $WD/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u439/results/golden_svtests.csv; echo "svtests rc=$? $(date +%T)"
