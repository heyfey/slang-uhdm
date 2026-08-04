#!/bin/bash
# r10rggen6shape: build+run the whole-design shape census (r10rgshape) over the
# Rggen golden/ours pair.  usage: r10rggen6shape.sh [head-lines]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_5b15da58-4bf-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen6_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rgshape.cpp -o /tmp/r10rggen6_shape \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
timeout 1800 /tmp/r10rggen6_shape "$G" "$S" > /tmp/r10rggen6_shape.txt 2>&1
echo "rc=$? lines=$(wc -l < /tmp/r10rggen6_shape.txt)"
grep -c 'r=\|SIZE' /tmp/r10rggen6_shape.txt
head -${1:-60} /tmp/r10rggen6_shape.txt
