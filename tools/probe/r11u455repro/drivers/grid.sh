#!/bin/bash
# grid.sh <binA> <tagA> <binB> <tagB> <casedir>...: one line per case dir:
# key | A: rc cmp verdict md5 | B: rc cmp verdict md5 | same/moved
D=$(dirname $0)
A=$1; TA=$2; B=$3; TB=$4; shift 4
for c in "$@"; do
  [ -d "$c" ] || continue
  a=$($D/run1.sh $c $A $TA | cut -d' ' -f2-)
  b=$($D/run1.sh $c $B $TB | cut -d' ' -f2-)
  ma=${a##*md5=}; mb=${b##*md5=}
  k=$(echo $c | sed 's|.*/cases/||')
  [ "$ma" = "$mb" ] && m=same || m=MOVED
  echo "$k | $a | $b | $m"
done
