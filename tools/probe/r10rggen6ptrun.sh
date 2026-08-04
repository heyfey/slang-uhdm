#!/bin/bash
# r10rggen6ptrun: build+run the parameter-typespec census on both sides, diff.
#   r10rggen6ptrun.sh [name-filter] [head]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_5b15da58-4bf-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen6_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rggen6pt.cpp -o /tmp/r10rggen6_pt \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
/tmp/r10rggen6_pt "$G" "$1" > /tmp/r10rggen6_ptg.txt
/tmp/r10rggen6_pt "$S" "$1" > /tmp/r10rggen6_pts.txt
diff /tmp/r10rggen6_ptg.txt /tmp/r10rggen6_pts.txt > /tmp/r10rggen6_pt.diff
echo "rows g=$(wc -l < /tmp/r10rggen6_ptg.txt) s=$(wc -l < /tmp/r10rggen6_pts.txt) diff=$(grep -c '^[<>]' /tmp/r10rggen6_pt.diff)"
head -${2:-40} /tmp/r10rggen6_pt.diff
