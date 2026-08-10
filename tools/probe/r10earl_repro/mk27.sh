#!/bin/bash
# mk27.sh -- derive the pass-27 script set from the pass-26 one, re-pointing W=
# at THIS worktree and renaming the /tmp namespaces.  Idempotent.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_469c0e7a-755-1
cd "$W/tools/probe/r10earl_repro" || exit 1
for f in bnd26.sh bndd26.sh cad26.sh dvd26.sh exi26.sh exid26.sh bis26.sh \
         cen26.sh hdiff26.sh ins26.sh nul26.sh sub26.sh dmp26.sh gate26.sh \
         run26.sh sweep26.sh dbg26.sh tsd26.sh pb26.sh rd26.sh; do
  [ -f "$f" ] || { echo "MISSING $f"; continue; }
  n=${f/26/27}
  sed -e "s#/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_12312157-e8d-1#$W#g" \
      -e "s#/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_2e0a5015-2c0-1#$W#g" \
      -e 's/r10earl26/r10earl27/g' \
      -e 's/r10e26_/r10e27_/g' \
      -e 's/ts26\.py/ts27.py/g' "$f" > "$n"
  chmod +x "$n"
  echo "made $n"
done
cp -f ts26.py ts27.py
echo "copied ts27.py"
