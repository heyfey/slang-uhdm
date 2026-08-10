#!/bin/bash
# gate19.sh <tag> -- the full pass-19 gate: goldens, u2r testflags vs the
# committed baseline, Surelog BOTH modes vs the committed baseline.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_7fd8273a-549-1
T=${1:-g}
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
echo "== goldens"
bash tests/check_goldens.sh 2>&1 | grep -c '^PASS'
echo "== u2r testflags"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
  --out "/tmp/r10earl20_${T}_u2r.csv" --workdir "/tmp/r10earl20_${T}_u2rw" \
  --jobs 3 --timeout 300 > "/tmp/r10earl20_${T}_u2r.log" 2>&1
wc -l < "/tmp/r10earl20_${T}_u2r.csv"
sort results/gate_uhdm2rtlil.csv > /tmp/r10earl20_u2rbase.txt
sort "/tmp/r10earl20_${T}_u2r.csv" > /tmp/r10earl20_u2rnew.txt
diff /tmp/r10earl20_u2rbase.txt /tmp/r10earl20_u2rnew.txt
echo "(u2r diff rc=$?)"
echo "== surelog both modes"
python3 scripts/verify_golden.py --corpus surelog --mode both \
  --out "/tmp/r10earl20_${T}_sl.csv" --workdir "/tmp/r10earl20_${T}_slw" \
  --jobs 3 --timeout 300 > "/tmp/r10earl20_${T}_sl.log" 2>&1
wc -l < "/tmp/r10earl20_${T}_sl.csv"
sort results/golden_surelog.csv > /tmp/r10earl20_slbase.txt
sort "/tmp/r10earl20_${T}_sl.csv" > /tmp/r10earl20_slnew.txt
diff /tmp/r10earl20_slbase.txt /tmp/r10earl20_slnew.txt
echo "(surelog diff rc=$?)"
