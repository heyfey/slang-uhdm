#!/bin/bash
# v11u424 full five-stage run: <binary> <workdir> <trace dir>
source /tmp/v11u424_env.sh || exit 2
export SLANG_UHDM=$1; WD=$2; export R11U424_TRACE=$3
for v in "$SLANG_UHDM" "$SURELOG" "$UHDM_CMP" "$UHDM_DUMP"; do [ -x "$v" ] || exit 2; done
mkdir -p $R11U424_TRACE
n=0; while [ $n -lt 3 ]; do if pgrep -f 'tests/swee[p].sh|svtests_matri[x]|check_svtest[s]|verify_golde[n]|check_prob[e]|downstream_uhdm2rtli[l]' >/dev/null; then n=0; else n=$((n+1)); fi; sleep 20; done
echo "start $(date) $(md5sum $SLANG_UHDM)"
cd /tmp/wt_v11u424
tests/sweep.sh --jobs 3 --workdir $WD --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir $WD/svtests --out $WD/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u424/results/golden_svtests.csv
echo "svtests rc=$? $(date)"
