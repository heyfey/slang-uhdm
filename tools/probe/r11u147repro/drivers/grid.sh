#!/bin/bash
# grid.sh <binA> <binB> <case dirs...>: one line per case: name | A verdict | B verdict (uhdm-cmp lines + strict)
A=$1; B=$2; shift 2
for d in "$@"; do
  ra=$(MAX=2 $(dirname $0)/rc.sh $d $A 2>/dev/null | tail -1 | sed 's/^[^ ]* [^ ]* //')
  rb=$(MAX=2 $(dirname $0)/rc.sh $d $B 2>/dev/null | tail -1 | sed 's/^[^ ]* [^ ]* //')
  printf '%-34s | %-48s | %s\n' "$(basename $(dirname $d))/$(basename $d)" "$ra" "$rb"
done
