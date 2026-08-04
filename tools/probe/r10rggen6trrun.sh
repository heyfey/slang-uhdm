#!/bin/bash
# r10rggen6trrun: build+run the parameter typespec-range census, diff sides.
#   r10rggen6trrun.sh [name-filter] [head]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_5b15da58-4bf-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen6_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rggen6tr.cpp -o /tmp/r10rggen6_tr \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
/tmp/r10rggen6_tr "$G" "$1" > /tmp/r10rggen6_trg.txt
/tmp/r10rggen6_tr "$S" "$1" > /tmp/r10rggen6_trs.txt
diff /tmp/r10rggen6_trg.txt /tmp/r10rggen6_trs.txt > /tmp/r10rggen6_tr.diff
echo "rows g=$(wc -l < /tmp/r10rggen6_trg.txt) s=$(wc -l < /tmp/r10rggen6_trs.txt) diff=$(grep -c '^[<>]' /tmp/r10rggen6_tr.diff)"
head -${2:-40} /tmp/r10rggen6_tr.diff
