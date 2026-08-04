#!/bin/bash
# r10rggen6parun: build+run the param_assign Rhs-constant census, diff sides.
#   r10rggen6parun.sh [name-filter] [head]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_5b15da58-4bf-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen6_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rggen6pa.cpp -o /tmp/r10rggen6_pa \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
/tmp/r10rggen6_pa "$G" "$1" > /tmp/r10rggen6_pag.txt
/tmp/r10rggen6_pa "$S" "$1" > /tmp/r10rggen6_pas.txt
diff /tmp/r10rggen6_pag.txt /tmp/r10rggen6_pas.txt > /tmp/r10rggen6_pa.diff
echo "rows g=$(wc -l < /tmp/r10rggen6_pag.txt) s=$(wc -l < /tmp/r10rggen6_pas.txt) diff=$(grep -c '^[<>]' /tmp/r10rggen6_pa.diff)"
head -${2:-40} /tmp/r10rggen6_pa.diff
