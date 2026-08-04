#!/bin/bash
# r10rggen7arun: build+run r10rggen7a on the Rggen pair (or a given pair).
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_72a14877-cd1-1
G=${G:-$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm}
S=${S:-$(cat /tmp/r10rggen7_slang.path)}
g++ -std=c++20 -O1 $W/tools/probe/r10rggen7a.cpp -o /tmp/r10rggen7_a \
  -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
timeout 600 /tmp/r10rggen7_a "$G" "$S" "$@"
