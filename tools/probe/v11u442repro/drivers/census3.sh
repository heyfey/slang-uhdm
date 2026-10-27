#!/bin/bash
# census3.sh <pristine> <law> <verified> <casedir>: one line "<dir> rcP rcL rcV P==L L==V P==V"
# outputs under /tmp/v11u442_scr/bc/<key>/{p,l,v}.uhdm, keyed on the full path
P=$1; L=$2; W=$3; c=$4
[ -x "$P" ] && [ -x "$L" ] && [ -x "$W" ] || { echo "BAD BIN"; exit 1; }
[ -d "$c" ] || exit 0
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
[ -f $c/dut.sv ] || [ -f $c/FILES ] || exit 0
GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
k=$(echo $c | tr / _); o=/tmp/v11u442_scr/bc/$k; mkdir -p $o; rm -f $o/p.uhdm $o/l.uhdm $o/v.uhdm
for t in p l v; do B=$P; [ $t = l ] && B=$L; [ $t = v ] && B=$W
  (cd $c && timeout 120 $B $SRC $GT --single-unit --nobuiltin -o $o/$t.uhdm >/dev/null 2>&1 </dev/null; echo $? > $o/r$t); done
m(){ md5sum < $o/$1.uhdm 2>/dev/null | cut -c1-12; }
a=$(m p); b=$(m l); d=$(m v)
e(){ [ "$1" = "$2" ] && echo = || echo X; }
echo "$c $(cat $o/rp) $(cat $o/rl) $(cat $o/rv) $(e $a $b) $(e $b $d) $(e $a $d)"
