#!/bin/bash
# predict.sh <sweep_root> <outdir>  (r11u139) — for every corpus row of a PRISTINE sweep, the refbind diff
# golden vs ours (which object every elaborated reference binds, and its full name).  A row with a nonzero
# diff is a PREDICTED mover of the net-binding laws; a row with none must not move.
root=$1; out=$2; RB=${RB:-/tmp/r11u139_refbind}; mkdir -p $out
one() {
  d=$1; out=$2; RB=$3
  key=$(echo $d | awk -F/ '{n=NF; t=$n; sub(/-[0-9a-f]+$/, "", t); print $(n-2)"."$(n-1)"."t}')
  g=$(grep -o 'goldens/[0-9a-f]*' $d/cmds.txt 2>/dev/null | head -1)
  gd=$HOME/.cache/slang-uhdm-$g
  [ -f $gd/golden.uhdm ] && [ -f $d/slang.uhdm ] || { echo "$key NA"; return; }
  timeout 600 $RB $gd/golden.uhdm > $out/$key.g 2>/dev/null
  timeout 600 $RB $d/slang.uhdm > $out/$key.s 2>/dev/null
  diff $out/$key.g $out/$key.s > $out/$key.diff
  n=$(grep -c '^[<>]' $out/$key.diff; true)
  rm -f $out/$key.g $out/$key.s
  [ "$n" = 0 ] && rm -f $out/$key.diff
  echo "$key $n"
}
export -f one
find $root/surelog $root/uhdm2rtlil -mindepth 2 -maxdepth 2 -type d | sort | xargs -P 4 -I{} bash -c 'one {} '"$out $RB"
