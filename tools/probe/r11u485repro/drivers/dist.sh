#!/bin/bash
# dist.sh <casedir-under-runs> <tagA> <tagB>: path-normalised dump distance golden->tagA and golden->tagB
source $(dirname "$0")/env.sh || exit 1
W=$1
d(){ $UHDM_DUMP "$1" 2>/dev/null | sed 1d | sed 's#file:[^,]*,#file:,#g'; }
d $W/sl/slpp_all/surelog.uhdm > /tmp/r11u485_dg.txt
for t in $2 $3; do d $W/$t.uhdm > /tmp/r11u485_dt.txt; echo -n "$t=$(diff /tmp/r11u485_dg.txt /tmp/r11u485_dt.txt | grep -c '^[<>]') "; done; echo
