#!/bin/bash
# r10uvm11sl.sh — the Surelog both-modes sweep alone.
set -u
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_0818e3af-a35-1
export SLANG_UHDM=$W/build/slang-uhdm
python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
  --out /tmp/r10uvm11_sl.csv --workdir /tmp/r10uvm11_slw --jobs 4
echo SLDONE
