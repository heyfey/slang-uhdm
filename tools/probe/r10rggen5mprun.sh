#!/bin/bash
# r10rggen5mprun: build+run the port-view census on both sides and diff.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_c688bbce-626-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen5_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rggen5mp.cpp -o /tmp/r10rggen5_mp \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
/tmp/r10rggen5_mp "$G" > /tmp/r10rggen5_mpg.txt
/tmp/r10rggen5_mp "$S" > /tmp/r10rggen5_mps.txt
diff /tmp/r10rggen5_mpg.txt /tmp/r10rggen5_mps.txt > /tmp/r10rggen5_mp.diff
echo "rows g=$(wc -l < /tmp/r10rggen5_mpg.txt) s=$(wc -l < /tmp/r10rggen5_mps.txt) diff=$(grep -c '^[<>]' /tmp/r10rggen5_mp.diff)"
head -${1:-30} /tmp/r10rggen5_mp.diff
