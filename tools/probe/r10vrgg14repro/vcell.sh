#!/usr/bin/env bash
# r10vrgg14 verifier cell driver — runs BOTH views (default and elab) for one
# arm dir with one binary.  Golden is cached per view.
#   usage: vcell.sh <celldir> <binary> <tag>
set -u
D=${1:?celldir}; BIN=${2:?binary}; TAG=${3:?tag}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/.local/bin/uhdm-cmp
cd "$D" || exit 3
for V in def elab; do
  SLF=""; SUF=""
  [ "$V" = elab ] && { SLF="-elabuhdm"; SUF="--elabuhdm"; }
  rm -rf slpp_all
  if [ ! -f "golden_$V.uhdm" ]; then
    "$SL" -parse -mt 0 -mp 0 $SLF *.sv > "sl_$V.log" 2>&1
    [ -f slpp_all/surelog.uhdm ] && cp slpp_all/surelog.uhdm "golden_$V.uhdm"
  fi
  rm -rf slpp_all
  "$BIN" *.sv --single-unit $SUF -o "ours_${TAG}_$V.uhdm" > "slang_${TAG}_$V.log" 2>&1
  rc=$?
  if [ -f "golden_$V.uhdm" ] && [ -f "ours_${TAG}_$V.uhdm" ]; then
    "$CMP" "golden_$V.uhdm" "ours_${TAG}_$V.uhdm" > "cmp_${TAG}_$V.txt" 2>&1
    echo "$(basename $D) $V $TAG rc=$rc cmplines=$(wc -l < cmp_${TAG}_$V.txt) heads=$(grep -c '^LHS:' cmp_${TAG}_$V.txt; true)"
  else
    echo "$(basename $D) $V $TAG MISSING-DB rc=$rc golden=$([ -f golden_$V.uhdm ] && echo y || echo n)"
  fi
done
