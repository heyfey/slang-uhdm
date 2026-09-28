#!/bin/bash
# v11u216 (copied from r11u216repro/drivers/widebytes.sh; binaries $BA and $BB, default law.bin and fix2.bin): the wide byte control.
# file naming several roots, or any other single .sv/.v file judged alone), both views:
# the pristine and the law binary (and, with OFFCHECK=1, the law binary under R11U216_OFF) write the database, and the
# md5s are compared; prints <dir> <view> same|MOVED [off=pristine|OFFDIFF].  No golden is built (movers are judged
# afterwards with case.sh).  Fence: a directory naming a fenced test is refused (drivers/env.sh, fail closed).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
W=${WBW:-/tmp/v11u216_wb}; mkdir -p $W
one() { f=$1; el=$2; c=$(dirname $f)
  for n in $FENCED; do echo "$f" | grep -qw "$n" && { echo "$f $el FENCED-SKIP"; return; }; done
  SRC=$(basename $f); [ "$SRC" = dut.sv ] && [ -f $c/args ] && SRC=$(cat $c/args)
  ox=""; [ $el = 1 ] && ox=--elabuhdm
  k=$(echo "$f $el" | md5sum | cut -c1-12)
  for b in ${BA:-law} ${BB:-fix2}; do rm -f $W/$k.$b.uhdm; (cd $c && timeout 300 $B/$b.bin $SRC --single-unit --nobuiltin $ox -o $W/$k.$b.uhdm > /dev/null 2>&1); done
  a=$(md5sum < $W/$k.${BA:-law}.uhdm 2>/dev/null | cut -c1-12); b=$(md5sum < $W/$k.${BB:-fix2}.uhdm 2>/dev/null | cut -c1-12)
  r="same"; [ "$a" != "$b" ] && r="MOVED"
  if [ "${OFFCHECK:-0}" = 1 ] && [ $r = MOVED ]; then
    rm -f $W/$k.off.uhdm; (cd $c && R11U216_OFF=1 timeout 300 $B/law.bin $SRC --single-unit --nobuiltin $ox -o $W/$k.off.uhdm > /dev/null 2>&1)
    o=$(md5sum < $W/$k.off.uhdm 2>/dev/null | cut -c1-12); [ "$o" = "$a" ] && r="$r off=pristine" || r="$r OFFDIFF"; fi
  rm -f $W/$k.*.uhdm
  echo "$f $el $r"; }
export -f one; export W B FENCED OFFCHECK BA BB
while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1'
