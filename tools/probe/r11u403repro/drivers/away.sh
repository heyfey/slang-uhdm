#!/bin/bash
# away.sh <relpath-without-.sv>: normalized dump diff line counts golden-vs-pristine and golden-vs-law
. /tmp/r11u403_scr/env.sh
t=$1; P=/tmp/r11u403_wdP/svtests/work/$t; L=/tmp/r11u403_wdG/svtests/work/$t
g=$(bash /tmp/r11u403_scr/gold.sh $L)
[ -f "$g" ] && [ -f $P/slang.uhdm ] && [ -f $L/slang.uhdm ] || { echo "$t NA"; exit; }
n(){ $UHDM_DUMP $1 2>&1 | sed -e 's/id:[0-9]*//' -e 's#file:[^,]*/#file:#' -e 1d | sort; }
G=/tmp/r11u403_scr/aw_$$; n $g > $G.g; n $P/slang.uhdm > $G.p; n $L/slang.uhdm > $G.l
a=$(diff $G.g $G.p | grep -c '^[<>]'); b=$(diff $G.g $G.l | grep -c '^[<>]'); rm -f $G.*
echo "$t pristine=$a law=$b"
