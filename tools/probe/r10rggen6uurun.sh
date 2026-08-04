#!/bin/bash
# r10rggen6uurun: build+run the unbased-unsized literal census on both sides.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_5b15da58-4bf-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen6_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rggen5uu.cpp -o /tmp/r10rggen6_uu \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
/tmp/r10rggen6_uu "$G" > /tmp/r10rggen6_uug.txt
/tmp/r10rggen6_uu "$S" > /tmp/r10rggen6_uus.txt
diff /tmp/r10rggen6_uug.txt /tmp/r10rggen6_uus.txt > /tmp/r10rggen6_uu.diff
echo "rows g=$(wc -l < /tmp/r10rggen6_uug.txt) s=$(wc -l < /tmp/r10rggen6_uus.txt) diff=$(grep -c '^[<>]' /tmp/r10rggen6_uu.diff)"
head -${1:-40} /tmp/r10rggen6_uu.diff
