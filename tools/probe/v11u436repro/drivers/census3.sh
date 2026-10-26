#!/bin/bash
# census3.sh <casedir>: pristine, law and verified (ver4) on one case dir, the same output path in turn
c=$1; P=/tmp/v11u436_bin/pristine; L=/tmp/v11u436_bin/law; V=/tmp/v11u436_bin/ver4
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g"); o=/tmp/v11u436_scr/census/$key; mkdir -p $o
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
run(){ rm -f $o/ours.uhdm; (cd $c && timeout 300 $1 $SRC $GT --single-unit --nobuiltin -o $o/ours.uhdm > /dev/null 2>&1 </dev/null; echo $?); }
rp=$(run $P); mp=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-12); cp $o/ours.uhdm $o/p.uhdm 2>/dev/null
rl=$(run $L); ml=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-12); cp $o/ours.uhdm $o/l.uhdm 2>/dev/null
rv=$(run $V); mv=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-12); cp $o/ours.uhdm $o/v.uhdm 2>/dev/null
echo "$c $rp ${mp:-none} $rl ${ml:-none} $rv ${mv:-none}"
