#!/bin/bash
# usage: gate7.sh [tag]   -> goldens + u2r testflags gate for this worktree
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_5ff5e790-346-1
export SLANG_UHDM=$W/build/slang-uhdm
T=${1:-g}
cd "$W" || exit 1
echo "== goldens"
bash tests/check_goldens.sh 2>&1 | grep -c '^PASS'
echo "== u2r testflags"
timeout 3000 python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
  --out "/tmp/r10earl12_u2r_$T.csv" --workdir "/tmp/r10earl12_u2r_${T}w" --jobs 3 2>&1 | tail -8
wc -l "/tmp/r10earl12_u2r_$T.csv"
diff <(sort results/gate_uhdm2rtlil.csv) <(sort "/tmp/r10earl12_u2r_$T.csv")
echo "u2r diff rc=$?"
