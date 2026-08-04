#!/bin/bash
# r10rggen7one: run ONE test of a corpus/mode and cmp-dump both sides.
#   r10rggen7one.sh <corpus> <mode> <TestName>
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_72a14877-cd1-1
export SLANG_UHDM=$W/build/slang-uhdm
rm -rf /tmp/r10rggen7_1w
python3 $W/scripts/verify_golden.py --corpus "$1" --mode "$2" \
  --filter "^$3\$" --out /tmp/r10rggen7_1.csv --workdir /tmp/r10rggen7_1w \
  --jobs 1 2>&1 | tail -3
cat /tmp/r10rggen7_1.csv
find /tmp/r10rggen7_1w -name '*.uhdm' | head -5
