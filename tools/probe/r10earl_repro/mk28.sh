#!/bin/bash
# mk28.sh -- derive the pass-28 script set from the pass-27 one, re-pointing W=
# at THIS worktree and renaming the /tmp namespaces.  Idempotent.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_0498617d-9bf-1
cd "$W/tools/probe/r10earl_repro" || exit 1
OLD=$(grep -ohE '/home/heyfey/git-repos/slang-uhdm/\.claude/worktrees/wf_[0-9a-zA-Z]+-[0-9a-zA-Z]+-[0-9]+' *27.sh 2>/dev/null | sort -u)
echo "OLDPATHS: $OLD"
for f in bnd27.sh bndd27.sh cad27.sh dvd27.sh exi27.sh exid27.sh bis27.sh \
         cen27.sh hdiff27.sh ins27.sh nul27.sh sub27.sh dmp27.sh gate27.sh \
         run27.sh sweep27.sh dbg27.sh tsd27.sh pb27.sh rd27.sh wit27.sh gld27.sh; do
  [ -f "$f" ] || { echo "MISSING $f"; continue; }
  n=${f/27/28}
  cp -f "$f" "$n"
  for o in $OLD; do sed -i "s#$o#$W#g" "$n"; done
  sed -i -e 's/r10earl27/r10earl28/g' -e 's/r10e27_/r10e28_/g' -e 's/ts27\.py/ts28.py/g' "$n"
  chmod +x "$n"
  echo "made $n"
done
cp -f ts27.py ts28.py
cp -f cast27.py cast28.py
cp -f ord27.py ord28.py
echo done
