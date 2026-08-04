#!/bin/bash
# r10uvm9sweep: run the UVM-4 filtered sweep (both modes) from this worktree.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e4a1375e-b25-1
export SLANG_UHDM=$W/build/slang-uhdm
rm -rf /tmp/r10uvm9_tw
timeout 3600 python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
  --filter "${1:-^(SeqDriver|SimpleUVM|Scoreboard|BuildUVMPkg)\$}" \
  --out /tmp/r10uvm9_t.csv --workdir /tmp/r10uvm9_tw --jobs "${2:-2}" 2>&1 | tail -5
echo "---"
cat /tmp/r10uvm9_t.csv
