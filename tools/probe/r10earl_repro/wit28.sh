#!/bin/bash
# wit27.sh <basename>... -- run each pass-27 witness and print ONLY its uhdm-cmp
# verdict line, so a whole witness set is one screen.  EQUAL = uhdm-cmp exit 0.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_0498617d-9bf-1/tools/probe/r10earl_repro
for f in "$@"; do
  bash "$W/run28.sh" "$f.sv" > "/tmp/r10earl28_wit_$f.log" 2>&1
  h=$(grep -m1 -A2 '^LHS:' "/tmp/r10earl28_wit_$f.log" | tail -1 | cut -c1-100)
  if [ -z "$h" ]; then
    echo "$f  EQUAL"
  else
    echo "$f  HEAD(LHS=golden): $h"
  fi
done
