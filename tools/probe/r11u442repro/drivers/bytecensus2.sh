#!/bin/bash
# bytecensus2.sh <pristine> <law> <casedir>: one line "<dir> rcP rcL same|MOVED" (outputs under /tmp/r11u442_scr/bc)
P=$1; L=$2; c=$3
[ -x "$P" ] && [ -x "$L" ] || { echo "BAD BIN"; exit 1; }
[ -d "$c" ] || exit 0
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
[ -f $c/dut.sv ] || [ -f $c/FILES ] || exit 0
GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
k=$(echo $c | tr / _); o=/tmp/r11u442_scr/bc/$k; mkdir -p $o; rm -f $o/p.uhdm $o/l.uhdm
(cd $c && timeout 120 $P $SRC $GT --single-unit --nobuiltin -o $o/p.uhdm >/dev/null 2>&1 </dev/null; echo $? > $o/rp)
(cd $c && timeout 120 $L $SRC $GT --single-unit --nobuiltin -o $o/l.uhdm >/dev/null 2>&1 </dev/null; echo $? > $o/rl)
a=$(md5sum < $o/p.uhdm 2>/dev/null | cut -c1-12); b=$(md5sum < $o/l.uhdm 2>/dev/null | cut -c1-12)
s=same; [ "$a" = "$b" ] || s=MOVED
echo "$c $(cat $o/rp) $(cat $o/rl) $s"
