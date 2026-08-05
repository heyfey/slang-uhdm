#!/bin/bash
# usage: slsweep4.sh <tag>   -> FULL Surelog both-modes sweep for this worktree
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_b2de9437-c1b-1
export SLANG_UHDM=$W/build/slang-uhdm
T=${1:-a}
cd "$W" || exit 1
timeout 3000 python3 scripts/verify_golden.py --corpus surelog --mode both \
  --out "/tmp/r10earl6_sl_$T.csv" --workdir "/tmp/r10earl6_sl_${T}w" --jobs 3
wc -l "/tmp/r10earl6_sl_$T.csv"
