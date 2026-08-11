#!/bin/bash
# r10uvm46 — regenerate ALL SIX t63 arm cells with the CURRENT binary and report,
# per cell, the interface census diff against golden AND uhdm-cmp's verdict.
# A cell that cannot be built or whose golden is missing is reported as FATAL,
# never as a pass: a driver that cannot find its input must not print success.
#   usage: arms.sh <tag>          e.g. arms.sh p1   -> /tmp/r10uvm46_t63a_p1 ...
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${1:?}
V=/tmp/r10uvm46_r10uvm46if
[ -x "$V" ] || { echo "FATAL: probe $V missing"; exit 3; }
rc=0
for a in t63a t63b t63c t63d t63e t63f; do
  OUT=/tmp/r10uvm46_${a}_$TAG
  bash "$HERE/gold.sh" "$a" "$OUT" > "$OUT.log" 2>&1
  if [ ! -f "$OUT/slpp_all/surelog.uhdm" ] || [ ! -f "$OUT/ours.uhdm" ]; then
    echo "FATAL $a: missing database (see $OUT.log)"; rc=3; continue
  fi
  "$V" "$OUT/slpp_all/surelog.uhdm" > "$OUT/if_g.txt" 2>/dev/null || {
    echo "FATAL $a: probe failed on golden"; rc=3; continue; }
  "$V" "$OUT/ours.uhdm" > "$OUT/if_o.txt" 2>/dev/null || {
    echo "FATAL $a: probe failed on ours"; rc=3; continue; }
  d=$(diff "$OUT/if_g.txt" "$OUT/if_o.txt" | grep -c '^[<>]')
  ~/.local/bin/uhdm-cmp "$OUT/slpp_all/surelog.uhdm" "$OUT/ours.uhdm" \
      > "$OUT/cmp.txt" 2>&1
  crc=$?
  if [ "$crc" = 0 ] && [ ! -s "$OUT/cmp.txt" ]; then cmp=EQUAL; else cmp=NOTEQUAL; fi
  echo "$a: ifcensus-diff=$d  uhdm-cmp=$cmp  (golden OBJ=$(grep -c '^OBJ' "$OUT/if_g.txt") ours OBJ=$(grep -c '^OBJ' "$OUT/if_o.txt"))"
done
exit $rc
