#!/usr/bin/env bash
# r10v118 VERIFIER's OWN arm driver.  Judge = the OFFICIAL uhdm-cmp.
#   usage: varm.sh <file.sv> <outdir-abs>
# every child </dev/null, rc RECORDED; both views; both frozen binaries.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
PRIS=/tmp/v118_bin/slang-uhdm-pristine
PATCHED=${VPATCHED:-/tmp/v118_bin/slang-uhdm-patched}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$2"; F=$(readlink -f "$1"); D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -d uhdm "$B" >sl.log 2>&1 </dev/null ); echo "SLrc=$?"
[ -f "$D/slpp_all/surelog.uhdm" ] && cp "$D/slpp_all/surelog.uhdm" "$D/g.uhdm"
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "PRISrc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "PRISErc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "PATCrc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "PATCErc=$?"
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || { echo "MISSING $t.uhdm"; continue; }
  "$DUMP" "$D/$t.uhdm" > "$D/$t.dump" 2>/dev/null
  # cast-op count (judge-visible operation) and loc-less-logic-typespec count
  nc=$(grep -c '|vpiOpType:67' "$D/$t.dump"); true
  printf "CASTOPS %-3s %s\n" "$t" "$nc"
done
for t in o oe q qe; do
  [ -f "$D/$t.uhdm" ] && [ -f "$D/g.uhdm" ] || continue
  "$CMP" "$D/g.uhdm" "$D/$t.uhdm" > "$D/$t.cmp" 2>&1
  n=$(grep -c . "$D/$t.cmp"); true
  h=$(grep -c '^LHS:' "$D/$t.cmp"); true
  printf "CMP %-3s lines=%s heads=%s\n" "$t" "$n" "$h"
done
