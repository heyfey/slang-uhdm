#!/bin/bash
# r10rggen8gsrun: build+run the gen-scope stepper (r10rggen6gs) at this head.
#   r10rggen8gsrun.sh <gen-scope-fullname-substring> [head] [all]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_f51a0e22-b08-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen8_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rggen6gs.cpp -o /tmp/r10rggen8_gs \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
timeout 1800 /tmp/r10rggen8_gs "$G" "$S" "$1" $3 > /tmp/r10rggen8_gs.txt 2>&1
echo "rc=$? lines=$(wc -l < /tmp/r10rggen8_gs.txt)"
head -${2:-60} /tmp/r10rggen8_gs.txt
