#!/bin/bash
# r10bbp7: re-run BlackBePipeInt (default mode) and report.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_512b5480-e53-1
export SLANG_UHDM=$W/build/slang-uhdm
rm -rf /tmp/r10bbp7_tw
python3 $W/scripts/verify_golden.py --corpus surelog --mode default \
  --filter '^BlackBePipeInt$' --out /tmp/r10bbp7_t.csv \
  --workdir /tmp/r10bbp7_tw --jobs 1 2>&1 | tail -3
cat /tmp/r10bbp7_t.csv
S=$(find /tmp/r10bbp7_tw -name slang.uhdm | head -1)
echo "slang=$S"
echo "$S" > /tmp/r10bbp7_slang.path
