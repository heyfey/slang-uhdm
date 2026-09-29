#!/bin/bash
# v11u224: switch reach on moved case-views. switches.sh <file of "casedir el"> : for each case-view, the law binary
# under each R11U224_<X>_OFF alone; prints the switches whose run writes the pristine binary's bytes.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
SW="STRPPESC STRCONTOWN IPSPFXJOIN IPSWIDTH LVSELIDX LVSELCOL LVNEWSPAN NEWARRIDXOP NEWARRVS SYSTYPEJOIN PCWALLPKG"
one() { c=$1; el=$2
  for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "$c FENCED"; return; }; done
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args); ox=""; [ $el = 1 ] && ox=--elabuhdm
  t=$S/sw/$(echo $c$el | md5sum | cut -c1-16); mkdir -p $t
  (cd $c && $B/pristine.bin $SRC --single-unit --nobuiltin $ox -o $t/p.uhdm >/dev/null 2>&1)
  r=""; for x in $SW; do rm -f $t/x.uhdm; (cd $c && env R11U224_${x}_OFF=1 $B/${LAWBIN:-law.bin} $SRC --single-unit --nobuiltin $ox -o $t/x.uhdm >/dev/null 2>&1); cmp -s $t/p.uhdm $t/x.uhdm && r="$r $x"; done
  echo "$(echo $c | sed 's#.*/cases/##; s#.*/tools/probe/#tp/#')$([ $el = 1 ] && echo _el) restored_by:${r:- NONE}"; rm -rf $t; }
export -f one; export SW HERE
cat ${1:?list} | xargs -P${GRIDJ:-3} -L1 bash -c 'one $0 $1' | sort
