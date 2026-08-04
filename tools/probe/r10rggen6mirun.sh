#!/bin/bash
# r10rggen6mirun: build+run the pass-5 module_inst stepper on the pass-6 pair.
#   r10rggen6mirun.sh <module-inst-fullname-substring> [head]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_5b15da58-4bf-1
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen6_slang.path)
g++ -std=c++20 -O1 $W/tools/probe/r10rggen5mi.cpp -o /tmp/r10rggen6_mi \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
timeout 1800 /tmp/r10rggen6_mi "$G" "$S" "$1" > /tmp/r10rggen6_mi.txt 2>&1
echo "rc=$? lines=$(wc -l < /tmp/r10rggen6_mi.txt)"
head -${2:-60} /tmp/r10rggen6_mi.txt
