#!/bin/bash
# r10bbp6: re-run BlackBePipeInt (default mode), re-census, re-cmp.
set -e
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_71fd1d8a-85c-1
export SLANG_UHDM=$W/build/slang-uhdm
G=/home/heyfey/.cache/slang-uhdm-goldens/c1bcb145248f6aa019f1/golden.uhdm
rm -rf /tmp/r10bbp6_tw
python3 $W/scripts/verify_golden.py --corpus surelog --mode default \
  --filter '^BlackBePipeInt$' --out /tmp/r10bbp6_t.csv \
  --workdir /tmp/r10bbp6_tw --jobs 1 2>&1 | tail -3
S=$(find /tmp/r10bbp6_tw -name slang.uhdm | head -1)
echo "slang=$S"
echo "$S" > /tmp/r10bbp6_slang.path
timeout 1800 /tmp/r10bbp6_ct "$G" "$S" 2>/dev/null | head -20
