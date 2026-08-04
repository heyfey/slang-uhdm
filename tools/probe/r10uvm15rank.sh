#!/bin/bash
# r10uvm15rank.sh [N] [ourdir] — rank the UVM-4 body residue by part+kind pair.
set -u
N=${1:-25}; O=${2:-/tmp/r10uvm15_m}
W=${R10WT:-/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_75dbb52e-067-1}
TMP=$(mktemp)
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  bash $W/tools/probe/r10uvm15p.sh $T "$O" part >> "$TMP"
done
awk -F'  *' '{n=$1; $1=""; sub(/^ +/,""); c[$0]+=n} END{for (k in c) printf "%8d  %s\n", c[k], k}' \
  "$TMP" | sort -rn | head -$N
rm -f "$TMP"
