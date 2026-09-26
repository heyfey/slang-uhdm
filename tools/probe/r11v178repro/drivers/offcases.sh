#!/bin/bash
# offcases.sh <binary> <tag> <reftag> <casedir...> -- ENV=VAL...: re-export each case (both modes) with ENV into
# <tag>.uhdm under the grid scratch and compare bytes with <reftag>.uhdm there.  Prints SAME/DIFF and a tally.
B=$1; T=$2; R=$3; shift 3; CS=(); while [ "$1" != "--" ]; do CS+=("$1"); shift; done; shift
same=0; diff=0
for c in "${CS[@]}"; do for e in "" 1; do
  line=$(ELAB=$e /tmp/v11u178_grid.sh $c $B $T "$@"); rel=${line%% *}
  if cmp -s /tmp/v11u178_g/$rel/$T.uhdm /tmp/v11u178_g/$rel/$R.uhdm; then same=$((same+1)); else diff=$((diff+1)); echo "DIFF $rel"; fi
done; done
echo "same=$same diff=$diff"
