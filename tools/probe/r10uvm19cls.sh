#!/bin/bash
# r10uvm19cls.sh "<Lkind> vs <Rkind>" [ourdir] — split one Compare pair class
# into the two families it always turns out to be: rows whose GOLDEN object
# sits inside a typespec RANGE (the declaration-inherited fold family, § 18/19)
# and everything else (a real expression).  This is what showed that the 332
# `constant vs operation` rows pass 19 inherited were 313 range rows plus 19
# genuinely-unfolded expressions.
set -u
F=$1; O=${2:-/tmp/r10uvm19_m}
P=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  bash "$P/r10uvm19p.sh" $T "$O" tree "" "$F" 2>/dev/null
done | awk '
  /^      Lp/ { if (index($0,"< range@")>0) r++; else o++ }
  END { printf "range-family %d   other %d\n", r+0, o+0 }'
