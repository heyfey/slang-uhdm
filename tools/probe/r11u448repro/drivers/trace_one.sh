#!/bin/bash
# usage: r11u448_dbg.sh <bin> <dut dir>  -> traces of 404/440/448
d=/tmp/r11u448_dbg; rm -rf $d; mkdir -p $d
cd $2 && R11U448_TRACE=$d R11U404_TRACE=$d R11U447_TRACE=$d $1 dut.sv --single-unit --nobuiltin -o $d/o.uhdm >/dev/null 2>$d/err; echo rc=$?; cat $d/err; grep -hv '^OUT' $d/*.4* 2>/dev/null
