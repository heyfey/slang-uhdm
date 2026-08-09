#!/bin/bash
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_d6db6f8b-3b4-1
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
bash tests/check_goldens.sh 2>&1 | tail -3
