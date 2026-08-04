#!/bin/bash
# r10uvm11all.sh — re-run every r10uvm11 repro pair and print its first-fail.
set -u
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_0818e3af-a35-1
for t in t1 t2 t3 t4; do
  $W/tools/probe/r10uvm11run.sh $W/tools/probe/r10uvm11repro/$t $t >/dev/null 2>&1
  echo "--- $t def"
  uhdm-cmp /tmp/r10uvm11_${t}_gd.uhdm /tmp/r10uvm11_${t}_sd.uhdm 2>&1 | sed -n '3p'
  echo "--- $t elab"
  uhdm-cmp /tmp/r10uvm11_${t}_ge.uhdm /tmp/r10uvm11_${t}_se.uhdm 2>&1 | sed -n '3p'
done
