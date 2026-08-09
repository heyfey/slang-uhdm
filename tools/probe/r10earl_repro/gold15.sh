#!/bin/bash
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_4f18c51a-913-1
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
bash tests/check_goldens.sh 2>&1 | tail -3
