#!/bin/bash
# r11u413 md5run.sh <binary> <casedir>: export dut.sv, print md5 of output and rc
B=$1; c=$2; t=$(echo "$B $c" | md5sum | cut -c1-12); O=/tmp/r11u413_scr/m_$t.uhdm; rm -f $O
(cd $c && timeout 120 $B dut.sv --single-unit --nobuiltin -o $O >/dev/null 2>&1); rc=$?
m=$( [ -f $O ] && md5sum < $O | cut -c1-12 || echo none); rm -f $O; echo "$c $rc $m"
