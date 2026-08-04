#!/bin/bash
# r10uvm9all: body-differ TOTALS for all four UVM tests (default mode).
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e4a1375e-b25-1
for t in BuildUVMPkg-bf853d43 Scoreboard-59431470 SeqDriver-32af76aa SimpleUVM-1dc93a62; do
  bash $W/tools/probe/r10uvm9b.sh $t default part >/dev/null 2>&1
  printf '%-24s %s\n' "$t" "$(awk '{s+=$1} END {print s}' /tmp/r10uvm9_b_${t}_default.txt)"
done
