#!/bin/bash
# vrk13.sh <basename> <param...>  -- r10earl10k on a witness for each param.
B=$1; shift
D=/tmp/r10earl16_rep/out_$B
G=$(ls "$D"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
for P in "$@"; do
  echo "--- $P"
  /tmp/r10earl10k "$G" "$D/ours.uhdm" "$P" 2>&1 | head -16
done
