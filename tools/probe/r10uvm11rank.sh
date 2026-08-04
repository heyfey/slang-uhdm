#!/bin/bash
# r10uvm11rank.sh [N] — rank the remaining UVM-4 body residue by part+kind pair.
set -u
N=${1:-25}
: > /tmp/r10uvm11_rank.txt
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d /tmp/r10uvm11_slw/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || continue
  G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)/golden.uhdm
  /tmp/r10uvm11_b "$G" "$D/slang.uhdm" part 2>/dev/null >> /tmp/r10uvm11_rank.txt
done
awk -F'  *' '{n=$1; $1=""; sub(/^ +/,""); c[$0]+=n} END{for (k in c) printf "%8d  %s\n", c[k], k}' \
  /tmp/r10uvm11_rank.txt | sort -rn | head -$N
