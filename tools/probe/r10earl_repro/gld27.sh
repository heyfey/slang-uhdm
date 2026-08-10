#!/bin/bash
# gld27.sh -- the 23 goldens alone, with SLANG_UHDM pinned to THIS worktree.
# SLANG_UHDM=/bin/false is the negative control: it must report 0.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_469c0e7a-755-1
export SLANG_UHDM=${SLANG_UHDM:-$W/build/slang-uhdm}
cd "$W" || exit 1
bash tests/check_goldens.sh > /tmp/r10earl27_gld.log 2>&1
echo "PASS=$(grep -c '^PASS' /tmp/r10earl27_gld.log) FAIL=$(grep -c '^FAIL' /tmp/r10earl27_gld.log)"
grep '^FAIL' /tmp/r10earl27_gld.log
