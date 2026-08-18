#!/usr/bin/env bash
# r10rgg15 cell driver — DEFAULT-MODE arms, mirroring verify_golden.py's
# `default` mode exactly: surelog gets `-parse <sources>`, slang gets
# `<sources> --single-unit`.  Both databases are dumped and cmp'd.
#   usage: cell14.sh <celldir> <binary> [outsuffix]
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
fi
rm -rf slpp_all   # a stray slpp_all/lib/work/<src>.sv is a COPY of the arm and
                  # shows up as a phantom boundary mover (r10rgg12 § 10)
"$BIN" *.sv --single-unit -o "ours$SFX.uhdm" > "slang$SFX.log" 2>&1
rc=$?
if [ -f golden.uhdm ] && [ -f "ours$SFX.uhdm" ]; then
  $HOME/.local/bin/uhdm-cmp golden.uhdm "ours$SFX.uhdm" > "cmp$SFX.txt" 2>&1
  echo "$(basename $D)$SFX slangrc=$rc cmplines=$(wc -l < cmp$SFX.txt) heads=$(grep -c '^LHS:' cmp$SFX.txt; true)"
else
  echo "$(basename $D)$SFX MISSING-DB golden=$([ -f golden.uhdm ] && echo y || echo n) ours=$([ -f ours$SFX.uhdm ] && echo y || echo n) slangrc=$rc"
fi
