#!/bin/bash
# r10uvm19fe.sh [ourdir] — histogram every failing pair whose GOLDEN side hangs
# DIRECTLY off a foreach_stmt, i.e. the loop-variable objects.  Prints
# "<golden> vs <ours>" counts.  Derives its sibling scripts from the SCRIPT's
# own path so it does not rot when this worktree is harvested.
set -u
O=${1:-/tmp/r10uvm19_m}
P=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  bash "$P/r10uvm19p.sh" $T "$O" tree "" "" 2>/dev/null
done | awk '
  /^[A-Z]/ { n=split($0,a,"] "); key=a[n]; next }
  /^      Lp/ { lp=$0; next }
  /^      Rp/ { if (index(lp,"Lp < foreach_stmt")>0) print key }
' | sort | uniq -c | sort -rn | head -20
