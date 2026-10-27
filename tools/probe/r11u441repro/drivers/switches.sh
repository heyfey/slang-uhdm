#!/bin/bash
# usage: switches.sh <out.tsv> <pristine bin> <law bin> <casedir>...
# per case: md5 of pristine, law, law with R11U441_OFF, law with the case's own switch
# (from its first line '// § <law>'); outputs under $WR (default /tmp/r11u441_sw)
WR=${WR:-/tmp/r11u441_sw}; out=$1; P=$2; L=$3; shift 3
[ -x "$P" ] && [ -x "$L" ] || { echo "missing binary"; exit 2; }
sw(){ case "$1" in
  sysCallEmptyArgEndPrevTok441) echo R11U441_EMPTYARGEND_OFF;;
  emptySlotArgEndPrevTok441) echo R11U441_EMPTYSLOTEND_OFF;;
  uninstIfaceIncDecBinds441) echo R11U441_IFACEINCDEC_OFF;;
  esac; }
: > $out
for c in "$@"; do
  c=$(readlink -f $c); key="$(basename $(dirname $c))/$(basename $c)"; d=$WR/$(echo $key | tr / _); mkdir -p $d; cp $c/dut.sv $d/dut.sv
  law=$(head -1 $d/dut.sv | tr -d '\r' | sed -n 's#^// § \(.*\)$#\1#p'); s=$(sw $law)
  # every run writes the same path (the database embeds its own output path)
  run(){ rm -f $d/out.uhdm $d/$1.uhdm; (cd $d && timeout 300 env $2 $3 dut.sv --single-unit --nobuiltin -o out.uhdm >/dev/null 2>&1 </dev/null); local rc=$?; echo "$rc $(md5sum < $d/out.uhdm 2>/dev/null | cut -c1-12)"; mv -f $d/out.uhdm $d/$1.uhdm 2>/dev/null; }
  p=$(run p "X441=1" $P); l=$(run l "X441=1" $L); o=$(run o "R11U441_OFF=1" $L); w=$(run w "$s=1" $L)
  echo -e "$key\t$law\tp=[$p]\tl=[$l]\toff=[$o]$([ "$o" = "$p" ] && echo SAME || echo DIFF)\t$s=[$w]$([ "$w" = "$p" ] && echo SAME || echo DIFF)" | tee -a $out
done
