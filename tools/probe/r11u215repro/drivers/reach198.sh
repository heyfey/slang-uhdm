#!/bin/bash
# r11u215 § landingSwitchReach215: on every case dir given, both views, the law binary's bytes under R11V198_OFF,
# under R11V198_VSSYS_OFF, and with no switch.  prints <case> <view> OFF==VSSYS? OFF==none?  (fence: env.sh)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LB=$1; shift; T=/tmp/r11u215_reach198; mkdir -p $T
for c in "$@"; do for f in $FENCED; do grep -qw "$f" <<< "$c" && continue 2; done
  SRC=dut.sv; [ -f "$c/args" ] && SRC=$(cat "$c/args")
  for E in "" --elabuhdm; do k=$(echo "$c$E" | md5sum | cut -c1-10); o=$T/$k; rm -rf $o; mkdir -p $o
    ( cd $c && $B/$LB $SRC --single-unit --nobuiltin $E -o $o/none.uhdm >/dev/null 2>&1
      R11V198_OFF=1 $B/$LB $SRC --single-unit --nobuiltin $E -o $o/off.uhdm >/dev/null 2>&1
      R11V198_VSSYS_OFF=1 $B/$LB $SRC --single-unit --nobuiltin $E -o $o/vs.uhdm >/dev/null 2>&1 )
    cmp -s $o/off.uhdm $o/vs.uhdm && a=OFF=VSSYS || a=OFF!=VSSYS
    cmp -s $o/off.uhdm $o/none.uhdm && b=OFF=none || b=OFF!=none
    echo "$(basename $(dirname $c))/$(basename $c) ${E:-parse} $a $b"
  done; done
