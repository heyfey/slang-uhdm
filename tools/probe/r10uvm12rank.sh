#!/bin/bash
# r10uvm12rank.sh [N] [ourdir] — rank the UVM-4 body residue by part+kind pair.
set -u
N=${1:-25}; O=${2:-/tmp/r10uvm12_m}
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_d9ea24db-18b-1
TMP=$(mktemp)
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  bash $W/tools/probe/r10uvm12p.sh $T "$O" part >> "$TMP"
done
awk -F'  *' '{n=$1; $1=""; sub(/^ +/,""); c[$0]+=n} END{for (k in c) printf "%8d  %s\n", c[k], k}' \
  "$TMP" | sort -rn | head -$N
rm -f "$TMP"
