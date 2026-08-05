#!/bin/bash
# r10uvm17rank.sh [N] [ourdir] [mode] — rank the UVM-4 body residue.
# mode = part (default, part+kind pair) | whycls (first-differing property)
set -u
N=${1:-25}; O=${2:-/tmp/r10uvm17_m}; M=${3:-part}
W=${R10WT:-/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_8e8c1173-cfe-1}
TMP=$(mktemp)
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  R10B=${R10B:-/tmp/r10uvm17_b} bash $W/tools/probe/r10uvm17p.sh $T "$O" $M >> "$TMP"
done
awk -F'  *' '{n=$1; $1=""; sub(/^ +/,""); c[$0]+=n} END{for (k in c) printf "%8d  %s\n", c[k], k}' \
  "$TMP" | sort -rn | head -$N
rm -f "$TMP"
