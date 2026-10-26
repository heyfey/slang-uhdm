#!/bin/bash
# bytecensus.sh <law bin> <pristine bin> <casedir>: one line "<casedir> <rc_p> <md5_p> <rc_l> <md5_l>";
# both binaries write the SAME output path in turn (a database embeds its own path).
L=$1; P=$2; c=$(cd $3 && pwd)
[ -x "$L" ] && [ -x "$P" ] || { echo "$c NOBIN"; exit; }
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
o=/tmp/v11u436_scr/census/$key; mkdir -p $o
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
run(){ rm -f $o/ours.uhdm; (cd $c && timeout 300 $1 $SRC $GT --single-unit --nobuiltin -o $o/ours.uhdm > /dev/null 2>&1 </dev/null; echo $?) ; }
rp=$(run $P); mp=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-12); cp $o/ours.uhdm $o/p.uhdm 2>/dev/null
rl=$(run $L); ml=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-12); cp $o/ours.uhdm $o/l.uhdm 2>/dev/null
echo "$c $rp ${mp:-none} $rl ${ml:-none}"
