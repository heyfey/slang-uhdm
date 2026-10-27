#!/bin/bash
# usage: switches.sh <out.tsv> <pristine bin> <law bin> <casedir>...
# per case: md5 of pristine, law, law with R11U439_OFF, law with the case's own switch
# (from its first line '// § <law>'); outputs under $WR (default /tmp/v11u439_sw)
WR=${WR:-/tmp/v11u439_sw}; out=$1; P=$2; L=$3; shift 3
[ -x "$P" ] && [ -x "$L" ] || { echo "missing binary"; exit 2; }
sw(){ case "$1" in
  uninstProgBodyAsUninstIface439) echo R11U439_UNINSTPROG_OFF;;
  uninstProgSubBodyAsUninstIface439) echo R11U439_UNINSTPROGSUB_OFF;;
  foreachLeadSkipPlaceholder439) echo R11U439_LEADSKIP_OFF;;
  foreachTrailSkipDropped439) echo R11U439_TRAILSKIP_OFF;;
  loopVarReadBindsModuleDecl439) echo R11U439_LVMODDECL_OFF;;
  esac; }
: > $out
for c in "$@"; do
  c=$(readlink -f $c); key="$(basename $(dirname $c))/$(basename $c)"; d=$WR/$(echo $key | tr / _); mkdir -p $d; cp $c/dut.sv $d/dut.sv
  law=$(head -1 $d/dut.sv | sed -n 's#^// § \(.*\)$#\1#p'); s=$(sw $law)
  # every run writes the same path (the database embeds its own output path)
  run(){ rm -f $d/out.uhdm $d/$1.uhdm; (cd $d && timeout 300 env $2 $3 dut.sv --single-unit --nobuiltin -o out.uhdm >/dev/null 2>&1 </dev/null); local rc=$?; echo "$rc $(md5sum < $d/out.uhdm 2>/dev/null | cut -c1-12)"; mv -f $d/out.uhdm $d/$1.uhdm 2>/dev/null; }
  p=$(run p "X439=1" $P); l=$(run l "X439=1" $L); o=$(run o "R11U439_OFF=1" $L); w=$(run w "$s=1" $L)
  echo -e "$key\t$law\tp=[$p]\tl=[$l]\toff=[$o]$([ "$o" = "$p" ] && echo SAME || echo DIFF)\t$s=[$w]$([ "$w" = "$p" ] && echo SAME || echo DIFF)" | tee -a $out
done
