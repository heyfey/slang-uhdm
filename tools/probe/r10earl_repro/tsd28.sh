#!/bin/bash
# tsd26.sh <basename>... -- run each witness, dump both sides and print the
# UNPACKED-DIMENSION table (ts28.py), UNEQUAL ROWS ONLY.  LHS(golden) = the
# G: columns.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_0498617d-9bf-1/tools/probe/r10earl_repro
for f in "$@"; do
  bash "$W/run26.sh" "$f.sv" > /tmp/r10earl28_tsd_$f.log 2>&1
  bash "$W/dmp26.sh" "$f" > /dev/null
  bash "$W/dvd26.sh" "$f" > /dev/null 2>&1
  echo "=== $f  (cmp head: $(grep -m1 -A2 '^LHS:' /tmp/r10earl28_tsd_$f.log | tail -1 | cut -c1-90))"
  python3 "$W/ts28.py" "/tmp/r10earl28_rep/out_$f/gdv.txt" \
      "/tmp/r10earl28_rep/out_$f/odv.txt" | grep -v ' equal$'
done
