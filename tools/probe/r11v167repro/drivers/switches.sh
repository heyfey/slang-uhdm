#!/bin/bash
# per case: trace set of ver.bin; for each switch: SAME/DIFF vs pristine under that switch
source ${ENVFILE:?export ENVFILE: the pin environment (SURELOG, UHDM_CMP, ..., FENCED)}
W=/tmp/v11u167_sw_tmp; mkdir -p $W
declare -A LAW=( [R11U167_TPSTRUCTUSE_OFF]=tpAnonStructLastParamUser167 [R11U167_TPSTRUCTSPAN_OFF]=tpAnonStructCopySpanAtKeyword167 [R11U167_PATCALLARG_OFF]=pkgPatCallArgReadNoParent167 [R11U167_S2CLONE_OFF]=evalFuncBodyRhsStampClone167 [R11U167_GSFOLDDECLTS_OFF]=genProcFoldDeclTsScopeNamed167 [R11U167_HPWS_OFF]=hpDotWsTrimmed167 )
for c in $(find $(cd $(dirname $0)/../.. && pwd)/r11u167repro/cases $(cd $(dirname $0)/.. && pwd)/cases -name dut.sv | sort); do
  dir=$(dirname $c); rel=$(echo $dir | sed 's#.*/tools/probe/##')
  (cd $dir && rm -f $W/p.u && /tmp/v11u167_bin/pris.bin dut.sv --single-unit --nobuiltin -o $W/p.u >/dev/null 2>&1)
  tr=$(cd $dir && rm -f $W/t.u && R11U167_TRACE=1 /tmp/v11u167_bin/ver.bin dut.sv --single-unit --nobuiltin -o $W/t.u 2>&1 >/dev/null | grep '^R11U167_TRACE' | awk '{print $2}' | sort -u | tr '\n' ',')
  out="$rel [$tr]"
  for s in "${!LAW[@]}"; do
    l=${LAW[$s]}; fired=0; grep -q "$l" <<<"$tr" && fired=1
    others=$(echo "$tr" | tr ',' '\n' | grep -v "^$l" | grep -v '^s2ClonePrecheck167v' | grep -c .)
    [ $fired = 0 ] && continue
    (cd $dir && rm -f $W/s.u && env $s=1 /tmp/v11u167_bin/ver.bin dut.sv --single-unit --nobuiltin -o $W/s.u >/dev/null 2>&1)
    if cmp -s $W/p.u $W/s.u; then r=PRIS; else r=diff; fi
    [ $others = 0 ] && out="$out $s:$r(alone)" || out="$out $s:$r"
  done
  echo "$out"
done
