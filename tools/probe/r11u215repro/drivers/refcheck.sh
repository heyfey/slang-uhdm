#!/bin/bash
# r11u215: the refinement switch R11V215_MEMBERREAD_OFF on the cases its trace (diagImpPatMemberRead215) names: with the
# switch the law binary writes what the unrefined law wrote (the base's decision dropped), without it the refined bytes.
# prints <case> <view> <#member-read skips> law==pristine? off==pristine?   usage: refcheck.sh <law bin> <case dir>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LB=$1; shift; T=/tmp/r11u215_refchk; mkdir -p $T
for c in "$@"; do for f in $FENCED; do grep -qw "$f" <<< "$c" && continue 2; done
  for E in "" --elabuhdm; do k=$(echo "$c$E" | md5sum | cut -c1-10); o=$T/$k; rm -rf $o; mkdir -p $o/tr
    ( cd $c && R11U215_TRACE=$o/tr $B/$LB dut.sv --single-unit --nobuiltin $E -o $o/law.uhdm >/dev/null 2>&1
      R11V215_MEMBERREAD_OFF=1 $B/$LB dut.sv --single-unit --nobuiltin $E -o $o/off.uhdm >/dev/null 2>&1
      $B/pris.bin dut.sv --single-unit --nobuiltin $E -o $o/pris.uhdm >/dev/null 2>&1 )
    n=$(cat $o/tr/*.T215 2>/dev/null | grep -c '^diagImpPatMemberRead215')
    cmp -s $o/law.uhdm $o/pris.uhdm && a=law=pristine || a=law!=pristine
    cmp -s $o/off.uhdm $o/law.uhdm && b=off=law || b=off!=law
    echo "$(basename $(dirname $c))/$(basename $c) ${E:-parse} skips=$n $a $b"
  done; done
