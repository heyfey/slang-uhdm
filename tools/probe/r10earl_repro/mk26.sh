#!/bin/bash
# mk26.sh -- derive the pass-26 script set from the pass-25 one, re-pointing W=
# at THIS worktree and renaming the /tmp namespaces.  Idempotent.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_12312157-e8d-1
cd "$W/tools/probe/r10earl_repro" || exit 1
for f in bnd25.sh bndd25.sh cad25.sh dvd25.sh exi25.sh bis25.sh cen25.sh \
         hdiff25.sh ins25.sh nul25.sh sub25.sh dmp25.sh gate25.sh run25.sh \
         sweep25.sh; do
  [ -f "$f" ] || { echo "MISSING $f"; continue; }
  n=${f/25/26}
  sed -e "s#/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_2e0a5015-2c0-1#$W#g" \
      -e 's/r10earl25/r10earl26/g' \
      -e 's/r10e24_/r10e26_/g' \
      -e 's/r10e25_/r10e26_/g' "$f" > "$n"
  chmod +x "$n"
  echo "made $n"
done
