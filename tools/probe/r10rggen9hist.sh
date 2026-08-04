#!/bin/bash
# r10rggen9hist: histogram of failLhs/failRhs pairs over the WHOLE elab gen tree.
# usage: r10rggen9hist.sh <want-regex, use '.' for all> [head-n]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e1b54aae-99d-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen9_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rggen6gs.cpp -o /tmp/r10rggen9_gs \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
timeout 1800 /tmp/r10rggen9_gs "$G" "$S" "$1" all > /tmp/r10rggen9_hist.txt 2>&1
echo "rc=$? lines=$(wc -l < /tmp/r10rggen9_hist.txt)"
grep 'failLhs' /tmp/r10rggen9_hist.txt | sed 's/^ *//' | sort | uniq -c | sort -rn | head -${2:-30}
