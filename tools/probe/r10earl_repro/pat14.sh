#!/bin/bash
# pat14.sh <witness-basename> [section...]  -- patab14.py on BOTH sides of a
# witness, golden block then ours, for each listing section.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_d6db6f8b-3b4-1
D=/tmp/r10earl14_rep/out_$1
shift
SECS=${*:-"uhdmallModules uhdmtopModules uhdmallPackages uhdmtopPackages"}
for S in $SECS; do
  echo "### $S  GOLDEN"
  python3 "$W/tools/probe/r10earl_repro/patab14.py" "$D/g.dump" "$S" 2>&1
  echo "### $S  OURS"
  python3 "$W/tools/probe/r10earl_repro/patab14.py" "$D/o.dump" "$S" 2>&1
done
