#!/bin/bash
c=$1; G=$($(dirname $0)/gd.sh $c); O=/tmp/r11u409_scr/rsz_$$.uhdm; rm -f $O; (cd $c && $2 dut.sv --single-unit --nobuiltin -o $O >/dev/null 2>&1)
python3 $(dirname $0)/rsz.py $c $G $O ${3:-R}; rm -f $O
