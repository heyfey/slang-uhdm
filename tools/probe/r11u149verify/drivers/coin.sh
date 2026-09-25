#!/bin/bash
# coin.sh <A workdir> <B workdir> <corpus> <mode/test-hash>...: order-blind dump diff of a byte mover (the UVM
# UINT/vpiDecompile order coin reads 0 or 4 lines, all UINT:/vpiDecompile:)
source /tmp/wt_r11u149/tools/probe/r11u149verify/drivers/env.sh
A=$1; B=$2; c=$3; shift 3
for p in "$@"; do
  a=$($UHDM_DUMP $A/$c/$p/slang.uhdm 2>/dev/null | sed -E "s#$A##g" | sort)
  b=$($UHDM_DUMP $B/$c/$p/slang.uhdm 2>/dev/null | sed -E "s#$B##g" | sort)
  d=$(diff <(echo "$a") <(echo "$b") | grep '^[<>]')
  n=$(echo -n "$d" | grep -c .); k=$(echo -n "$d" | grep -vc 'UINT:\|vpiDecompile:')
  echo "$c/$p orderblind_lines=$n non_UINT_decompile=$k"
done
