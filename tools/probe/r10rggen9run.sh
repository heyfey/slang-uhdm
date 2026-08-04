#!/bin/bash
# r10rggen9: re-run Rggen (default mode) and cmp against golden.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e1b54aae-99d-1
export SLANG_UHDM=$W/build/slang-uhdm
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
rm -rf /tmp/r10rggen9_tw
python3 $W/scripts/verify_golden.py --corpus surelog --mode default \
  --filter '^Rggen$' --out /tmp/r10rggen9_t.csv \
  --workdir /tmp/r10rggen9_tw --jobs 1 2>&1 | tail -3
S=$(find /tmp/r10rggen9_tw -name slang.uhdm | head -1)
echo "slang=$S"
echo "$S" > /tmp/r10rggen9_slang.path
timeout 1800 $HOME/git-repos/UHDM/build/bin/uhdm-cmp "$G" "$S" > /tmp/r10rggen9_cmp.txt 2>&1
echo "cmp lines=$(wc -l < /tmp/r10rggen9_cmp.txt)"
head -${1:-40} /tmp/r10rggen9_cmp.txt
