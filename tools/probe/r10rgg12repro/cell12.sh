#!/usr/bin/env bash
# r10rgg12 cell driver -- DEFAULT-MODE arms, mirroring verify_golden.py's
# `default` mode exactly: surelog gets `-parse <sources>`, slang gets
# `<sources> --single-unit`.  Both databases are dumped and cmp'd.
#   usage: cell.sh <celldir> <binary> [outsuffix]
set -u
D=${1:?celldir}
BIN=${2:?binary}
SFX=${3:-}
SL=$HOME/git-repos/Surelog/build/bin/surelog
cd "$D" || exit 3
rm -rf slpp_all
if [ ! -f golden.uhdm ]; then
  "$SL" -parse -mt 0 -mp 0 *.sv > sl.log 2>&1
  [ -f slpp_all/surelog.uhdm ] && cp slpp_all/surelog.uhdm golden.uhdm
  [ -f golden.uhdm ] && $HOME/git-repos/UHDM/build/bin/uhdm-dump golden.uhdm > golden.dump 2>/dev/null
fi
"$BIN" *.sv --single-unit -o "ours$SFX.uhdm" > "slang$SFX.log" 2>&1
rc=$?
[ -f "ours$SFX.uhdm" ] && $HOME/git-repos/UHDM/build/bin/uhdm-dump "ours$SFX.uhdm" > "ours$SFX.dump" 2>/dev/null
if [ -f golden.uhdm ] && [ -f "ours$SFX.uhdm" ]; then
  $HOME/.local/bin/uhdm-cmp golden.uhdm "ours$SFX.uhdm" > "cmp$SFX.txt" 2>&1
  echo "$(basename $D)$SFX slangrc=$rc cmplines=$(wc -l < cmp$SFX.txt) heads=$(grep -c '^LHS:' cmp$SFX.txt; true)"
else
  echo "$(basename $D)$SFX MISSING-DB golden=$([ -f golden.uhdm ] && echo y || echo n) ours=$([ -f ours$SFX.uhdm ] && echo y || echo n) slangrc=$rc"
fi
