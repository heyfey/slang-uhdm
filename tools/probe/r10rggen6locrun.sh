#!/bin/bash
# r10rggen6locrun: run the object locator on both sides.
#   r10rggen6locrun.sh <line> <col> [type-substring] [head]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_5b15da58-4bf-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen6_slang.path)
[ -x /tmp/r10rggen6_loc ] || \
g++ -std=c++20 -O1 $W/tools/probe/r10rggen6loc.cpp -o /tmp/r10rggen6_loc \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
echo "== GOLDEN"
/tmp/r10rggen6_loc "$G" "$1" "$2" "$3" | head -${4:-20}
echo "== OURS"
/tmp/r10rggen6_loc "$S" "$1" "$2" "$3" | head -${4:-20}
