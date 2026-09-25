#!/bin/bash
# switches.sh <law binary>: for each r11u167 switch, every case of cases/ exported with that switch
# alone; prints the cases whose database bytes differ from the law binary's (the switch's reach),
# with the law each case names on its first line, and the switched verdict next to pristine's (P).
L=$1; D=$(cd $(dirname $0) && pwd); cd $D/..
declare -A SW=( [R11U167_TPSTRUCTUSE_OFF]=tpAnonStructLastParamUser167 [R11U167_TPSTRUCTSPAN_OFF]=tpAnonStructCopySpanAtKeyword167
  [R11U167_PATCALLARG_OFF]=pkgPatCallArgReadNoParent167 [R11U167_S2CLONE_OFF]=evalFuncBodyRhsStampClone167
  [R11U167_GSFOLDDECLTS_OFF]=genProcFoldDeclTsScopeNamed167 [R11U167_HPWS_OFF]=hpDotWsTrimmed167 )
mkdir -p /tmp/r11u167_x
for sw in $(echo ${!SW[@]} | tr ' ' '\n' | sort); do
  echo "== $sw (${SW[$sw]})"
  for c in cases/*/*; do
    rel=${c#cases/}
    drivers/grid.sh $c $L LAW >/dev/null
    env $sw=1 drivers/grid.sh $c $L SW > /tmp/r11u167_x/sw.line
    if ! cmp -s /tmp/r11u167_g/$rel/SW.uhdm /tmp/r11u167_g/$rel/LAW.uhdm; then
      v=$(sed 's/.*strict=\([^ ]*\).*/\1/' /tmp/r11u167_x/sw.line); p=$(tail -1 /tmp/r11u167_g/$rel/P.strict 2>/dev/null | tr ' ' _)
      echo "  $rel [$(head -1 $c/dut.sv | sed 's#// § ##')] switched=$v pristine=$p"
    fi
  done
done
