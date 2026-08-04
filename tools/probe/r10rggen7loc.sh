#!/bin/bash
# r10rggen7loc: cut-instance localizer over the Rggen pair (r10fsv3d).
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_72a14877-cd1-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen7_slang.path)
g++ -std=c++17 -O1 -I$HOME/.local/include $W/tools/probe/r10fsv3d.cpp \
  -o /tmp/r10rggen7_loc -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
timeout 1800 /tmp/r10rggen7_loc "$G" "$S" > /tmp/r10rggen7_loc.txt 2>&1
echo "rc=$? lines=$(wc -l < /tmp/r10rggen7_loc.txt)"
head -${1:-60} /tmp/r10rggen7_loc.txt
