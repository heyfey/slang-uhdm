#!/bin/bash
# svdumpcmp.sh <wdA> <wdB> <list> : per listed test, are the normalised uhdm-dumps equal?
. /tmp/v11u402_env.sh
A=$1; B=$2
one(){ k=$1; A=$2; B=$3; k=${k%.sv}; a=$A/work/$k/slang.uhdm; b=$B/work/$k/slang.uhdm
  if [ ! -f $a ] || [ ! -f $b ]; then echo "$k ASYM"; return; fi
  ha=$($UHDM_DUMP $a 2>&1 | tail -n +2 | sed "s#$A/#WD/#g" | md5sum | cut -c1-12); hb=$($UHDM_DUMP $b 2>&1 | tail -n +2 | sed "s#$B/#WD/#g" | md5sum | cut -c1-12)
  [ $ha = $hb ] && echo "$k SAME" || echo "$k MOVED"; }
export -f one
awk '{print $1}' $3 | xargs -P 3 -I{} bash -c "one {} $A $B"
