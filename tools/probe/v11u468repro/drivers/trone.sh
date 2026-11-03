#!/bin/bash
# trone.sh <casedir>: runs ver1 with the trace into a fresh dir, prints law counts
c=$1; T=$(mktemp -d /tmp/v11u468_tr.XXXXXX)
cd $c; F=dut.sv; [ -f FILES ] && F=$(cat FILES)
R11U468_TRACE=$T /tmp/v11u468_bin/ver1 $F --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1
cat $T/*.468 2>/dev/null | awk '{print $1}' | grep -v OUT | sort | uniq -c | tr '\n' ' '
