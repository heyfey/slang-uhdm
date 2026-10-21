#!/bin/bash
# bytes.sh <casedir>: run pristine and law, print key rcP rcL md5P md5L
c=$1; key=$(echo $c | sed 's|/tmp/wt_v11u424/tools/probe/||; s|/|_|g')
o=/tmp/v11u424_scr/cen/$key; rm -rf $o; mkdir -p $o
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
for t in p l; do b=/tmp/v11u424_bin/pristine; [ $t = l ] && b=/tmp/v11u424_bin/law
  [ -x $b ] || exit 1
  (cd $c && timeout 300 $b $SRC $GT --single-unit --nobuiltin -o $o/$t.uhdm > $o/$t.log 2>&1; echo $? > $o/$t.rc); done
mp=$( [ -f $o/p.uhdm ] && md5sum < $o/p.uhdm | cut -c1-8 || echo none); ml=$( [ -f $o/l.uhdm ] && md5sum < $o/l.uhdm | cut -c1-8 || echo none)
echo "$c $(cat $o/p.rc) $(cat $o/l.rc) $mp $ml"
[ "$mp" = "$ml" ] && rm -f $o/p.uhdm $o/l.uhdm
