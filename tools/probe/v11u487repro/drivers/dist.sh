#!/bin/bash
# dist.sh <casedir> <tagA> <tagB>: path-normalised dump distance golden->tagA and golden->tagB
source $(dirname "$0")/env.sh || exit 1
W=/tmp/v11u487_runs$(realpath $1)
d(){ $UHDM_DUMP "$1" 2>/dev/null | sed 1d | sed 's#file:[^,]*,#file:,#g'; }
d $W/sl/slpp_all/surelog.uhdm > /tmp/v11u487_dg.txt
for t in $2 $3; do d $W/$t.uhdm > /tmp/v11u487_dt.txt; echo -n "$t=$(diff /tmp/v11u487_dg.txt /tmp/v11u487_dt.txt | grep -c '^[<>]') "; done; echo
