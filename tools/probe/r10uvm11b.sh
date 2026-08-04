#!/bin/bash
# r10uvm11b.sh <workdir-root> <mode> — body-residue totals for the UVM four.
set -u
R=${1:-/tmp/r10uvm11_slw}; M=${2:-default}
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d $R/$M/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T ?"; continue; }
  G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)/golden.uhdm
  N=$(/tmp/r10uvm11_b "$G" "$D/slang.uhdm" rows 2>/dev/null | grep -c '^    L ')
  echo "$T $N"
done
