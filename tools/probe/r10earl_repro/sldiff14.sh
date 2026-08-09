#!/bin/bash
# sldiff14.sh <tag>  -- the Surelog both-modes sweep diff vs the committed
# baseline (results/golden_surelog.csv), sorted so row order cannot lie.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_d6db6f8b-3b4-1
cd "$W" || exit 1
sort results/golden_surelog.csv > /tmp/r10earl14_sl_base_sorted.csv
sort "/tmp/r10earl14_sl_$1.csv" > /tmp/r10earl14_sl_new_sorted.csv
diff /tmp/r10earl14_sl_base_sorted.csv /tmp/r10earl14_sl_new_sorted.csv
echo "sl diff rc=$?"
