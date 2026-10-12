#!/bin/bash
# v11u303 crashscan.sh <case dir>: the exit-code scan of the fix binary ($BIN) over the trigger list (fence-filtered by the caller); prints rc >= 124.
# rc scan: prints "<dir> rc=<n>" for every case dir where $BIN exits >= 128 (dir list already fence-filtered)
c=$1; k=$(echo $c | md5sum | cut -c1-12); SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
(cd $c && timeout 120 $BIN $SRC --single-unit --nobuiltin -o /tmp/v11u303_trig/o/c$k.uhdm >/dev/null 2>&1); rc=$?
rm -f /tmp/v11u303_trig/o/c$k.uhdm; [ $rc -ge 124 ] && echo "$c rc=$rc"
exit 0
