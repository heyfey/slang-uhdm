#!/bin/bash
# r10rggen7shape: whole-design shape census (r10rgshape) over the Rggen pair.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_72a14877-cd1-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen7_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rgshape.cpp -o /tmp/r10rggen7_shape \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
timeout 1800 /tmp/r10rggen7_shape "$G" "$S" > /tmp/r10rggen7_shape.txt 2>&1
echo "rc=$? lines=$(wc -l < /tmp/r10rggen7_shape.txt)"
grep -c 'r=\|SIZE' /tmp/r10rggen7_shape.txt
head -${1:-60} /tmp/r10rggen7_shape.txt
