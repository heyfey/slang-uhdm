#!/bin/bash
# uvmheads.sh <svwork> <list> : uhdm-cmp first object per row (line 3 of the head)
. /tmp/v11u402_env.sh
one(){ k=$1; W=$2; g=$(grep -o 'golden cache hit [^)]*' $W/work/$k/cmds.txt | awk '{print $4}'); g=$(ls $g/*.uhdm 2>/dev/null | head -1)
  h=$(timeout 900 $UHDM_CMP $g $W/work/$k/slang.uhdm 2>&1 | sed -n 3p | sed -E 's/, id:[0-9]+//' | cut -c1-90); echo "$k | $h"; }
export -f one
cat $2 | xargs -P 2 -I{} bash -c "one {} $1"
