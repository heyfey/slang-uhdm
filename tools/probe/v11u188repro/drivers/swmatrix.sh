#!/bin/bash
# v11u188: swmatrix.sh <list of case dirs, absolute> <out dir>: md5 of the database of every case under pris.bin (P),
# law.bin (L), v2.bin (V), v2.bin with R11U188_OFF (V_OFF), law.bin with R11U188_OFF (L_OFF), v2.bin with
# R11V188_MACROEXP_OFF (V_MAC) and v2.bin with each r11u188 switch alone.  Fenced paths are skipped.
. "$(dirname "$0")/env.sh" || exit 9
LIST=$1; OUT=$2; mkdir -p $OUT /tmp/v11u188_swm_tmp
run1() {
  local d=$1; local id=$(echo "$d" | md5sum | cut -c1-12)
  v188_fenced "$d" && return
  local top=dut.sv; [ ! -f "$d/dut.sv" ] && [ -f "$d/dut.v" ] && top=dut.v
  local line="$d"
  for v in "P|$V188_BIN/pris.bin|" "L|$V188_BIN/law.bin|" "V|$V188_BIN/v2.bin|" "V_OFF|$V188_BIN/v2.bin|R11U188_OFF=1" "L_OFF|$V188_BIN/law.bin|R11U188_OFF=1" "V_MAC|$V188_BIN/v2.bin|R11V188_MACROEXP_OFF=1" "V_PROPLAST|$V188_BIN/v2.bin|R11U188_PROPLAST_OFF=1" "V_BINDPARENT|$V188_BIN/v2.bin|R11U188_BINDPARENT_OFF=1" "V_TPKEYWORD|$V188_BIN/v2.bin|R11U188_TPKEYWORD_OFF=1" "V_TPDEFSYN|$V188_BIN/v2.bin|R11U188_TPDEFSYN_OFF=1" "V_TPINCORDER|$V188_BIN/v2.bin|R11U188_TPINCORDER_OFF=1" "V_SVMODE|$V188_BIN/v2.bin|R11U188_SVMODE_OFF=1"; do
    IFS='|' read n b e <<< "$v"
    local o=/tmp/v11u188_swm_tmp/$id.$n.uhdm; rm -f $o
    ( cd "$d" && env $e "$b" $top --single-unit --nobuiltin -o $o > /dev/null 2>&1 )
    if [ -s $o ]; then line="$line $n=$(md5sum < $o | cut -c1-10)"; else line="$line $n=NONE"; fi
    rm -f $o
  done
  echo "$line"
}
export -f run1 v188_fenced
xargs -P 3 -I{} bash -c 'run1 {}' < $LIST > $OUT/matrix.txt
