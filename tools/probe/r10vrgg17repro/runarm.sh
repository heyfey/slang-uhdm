#!/usr/bin/env bash
# vrgg17 arm driver: BOTH views (default -parse / elab -elabuhdm), three
# databases (golden, base, patched), for one cell directory.
#   usage: runarm.sh <celldir> <basebin> <patbin>
set -u
D=${1:?}; BB=${2:?}; PB=${3:?}
SL=$HOME/git-repos/Surelog/build/bin/surelog
cd "$D" || exit 3
for view in plain elab; do
  case $view in plain) SF=""; XF="";; elab) SF="-elabuhdm"; XF="--elabuhdm";; esac
  rm -rf slpp_all
  "$SL" -parse $SF -mt 0 -mp 0 *.sv > sl.$view.log 2>&1 </dev/null
  slrc=$?
  [ -f slpp_all/surelog.uhdm ] && cp slpp_all/surelog.uhdm golden.$view.uhdm
  rm -rf slpp_all
  "$BB" *.sv --single-unit $XF -o ours.base.$view.uhdm > slang.base.$view.log 2>&1 </dev/null
  brc=$?
  "$PB" *.sv --single-unit $XF -o ours.pat.$view.uhdm  > slang.pat.$view.log  2>&1 </dev/null
  prc=$?
  gm=$( [ -f golden.$view.uhdm ] && md5sum golden.$view.uhdm | cut -c1-12 || echo NONE )
  bm=$( [ -f ours.base.$view.uhdm ] && md5sum ours.base.$view.uhdm | cut -c1-12 || echo NONE )
  pm=$( [ -f ours.pat.$view.uhdm ] && md5sum ours.pat.$view.uhdm | cut -c1-12 || echo NONE )
  same=$( [ "$bm" = "$pm" ] && echo SAME || echo MOVED )
  echo "$(basename $D) $view slrc=$slrc brc=$brc prc=$prc golden=$gm base=$bm pat=$pm $same"
done
