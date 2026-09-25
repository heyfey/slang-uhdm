#!/bin/bash
# switches.sh <law binary>: for each r11u163 switch, every case of cases/ exported with that switch
# alone; prints the cases whose database bytes differ from the law binary's (the switch's reach),
# with the law each case names on its first line, and whether the switched verdict equals pristine's.
L=$1; D=$(cd $(dirname $0) && pwd); cd $D/..
declare -A SW=( [R11U163_AGGFOLDYNAME_OFF]=elabAggFoldYCopyDefNamed163 [R11U163_AGGQUALSPAN_OFF]=aggParamFoldQualSpanByView163
  [R11U163_OVARRDEFTS_OFF]=elabOvArrFoldSharesDefParamTs163 [R11U163_OVPATCOPY_OFF]=ovPkgPatOpInstanceCopy163
  [R11U163_TPDIMDEF_OFF]=elabTpNamedElemDimDefNamed163 [R11U163_TPDEFNAME_OFF]=elabTpDefaultDefNamed163
  [R11U163_OPCLONERELOC_OFF]=paramOpCloneRelocatedSpan163 [R11U163_IMPOPNAME_OFF]=importPatOpCloneParamNamed163
  [R11U163_PATLISTCOPY_OFF]=pkgPatListingCopyWhenShared163 [R11U163_FNPNETFILE_OFF]=fnParamRangeNetNoFile163 )
for sw in $(echo ${!SW[@]} | tr ' ' '\n' | sort); do
  echo "== $sw (${SW[$sw]})"
  for c in cases/*/*; do
    rel=${c#cases/}
    drivers/grid.sh $c $L LAW >/dev/null
    env $sw=1 drivers/grid.sh $c $L SW > /tmp/r11u163_x/sw.line
    if ! cmp -s /tmp/r11u163_g/$rel/SW.uhdm /tmp/r11u163_g/$rel/LAW.uhdm; then
      v=$(awk '{print $5}' /tmp/r11u163_x/sw.line); p=$(tail -1 /tmp/r11u163_g/$rel/PRIS.strict 2>/dev/null | tr ' ' _)
      echo "  $rel [$(head -1 $c/dut.sv | sed 's#// § ##')] switched=$v pristine=strict=$p"
    fi
  done
done
