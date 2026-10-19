#!/bin/bash
# away.sh <relpath>: order-blind normalized dump diff counts vs golden, pristine and law
. /tmp/v11u403_scr/env.sh
t=$1; P=/tmp/v11u403_wdP/svtests/work/$t; L=/tmp/v11u403_wdL/svtests/work/$t
g=$(sed -n 's/.*cache hit \(.*\))/\1/p' $L/cmds.txt 2>/dev/null); if [ -n "$g" ]; then g=$g/golden.uhdm; else g=$L/slpp_all/surelog.uhdm; fi
[ -f "$g" ] && [ -f $P/slang.uhdm ] && [ -f $L/slang.uhdm ] || { echo "$t NA"; exit; }
n(){ $UHDM_DUMP $1 2>&1 | sed -e 's/id:[0-9]*//' -e 's#file:[^,]*/#file:#' -e 1d | sort; }
G=/tmp/v11u403_scr/aw_$$; n $g > $G.g; n $P/slang.uhdm > $G.p; n $L/slang.uhdm > $G.l
a=$(diff $G.g $G.p | grep -c '^[<>]'); b=$(diff $G.g $G.l | grep -c '^[<>]'); rm -f $G.*
echo "$t pristine=$a law=$b"
