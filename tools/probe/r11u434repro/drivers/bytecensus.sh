#!/bin/bash
# bytecensus.sh <casedir>: md5 of pristine vs law4 database for one case dir (no golden)
c=$1; [ -d "$c" ] && [ -f "$c/dut.sv" ] || exit 0
key=$(echo $c | sed "s|.*/tools/probe/||; s|.*/tests/probe/|tp_|; s|/|_|g")
o=/tmp/r11u434_bc/$key; mkdir -p $o
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
for b in pristine law4; do rm -f $o/$b.uhdm; (cd $c && timeout 120 /tmp/r11u434_bin/$b $SRC $GT --single-unit --nobuiltin -o $o/$b.uhdm >/dev/null 2>&1; echo $? > $o/$b.rc); done
mp=$(md5sum < $o/pristine.uhdm 2>/dev/null | cut -c1-8); ml=$(md5sum < $o/law4.uhdm 2>/dev/null | cut -c1-8)
echo "$([ "$mp" = "$ml" ] && [ "$(cat $o/pristine.rc)" = "$(cat $o/law4.rc)" ] && echo SAME || echo MOVE) $c rc=$(cat $o/pristine.rc)/$(cat $o/law4.rc)"
