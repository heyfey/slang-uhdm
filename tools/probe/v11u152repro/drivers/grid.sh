#!/bin/bash
# grid.sh <cases-root> [P L] : pris / law / R11U152_OFF / own switch per case, v11u152
R=$1; P=${2:-/tmp/v11u152_bin/pris.bin}; L=${3:-/tmp/v11u152_bin/law.bin}
declare -A SW=(
 [portConnParamFoldAtActual152]=R11U152_C3_OFF [genLpOperandTsNoParent152]=R11U152_GENLPOPTS_OFF
 [crossPkgFoldTsNameOnChain152]=R11U152_FOLDCHAIN_OFF [tpElemPatAtUser152]=R11U152_TPELEMPAT_OFF
 [pkgElemMemberPatNoLoc152]=R11U152_PKGELEMPAT_OFF [packedElemAliasTypedef152]=R11U152_ELEMALIAS_OFF
 [tpOvrTypedefStructSpan152]=R11U152_TPOVRSTRUCT_OFF [genCaseItemUnnamed152]=R11U152_GENCASE_OFF
 [delayLiteralValueText152]=R11U152_DLYREAL_OFF [unsupportedTsInitEnd152]=R11U152_CGINITEND_OFF
 [classVarInitSpan152]=R11U152_CLSVARINIT_OFF [classSpecNestedAtName152]=R11U152_CLSNESTNAME_OFF
 [classSpecPaNoFile152]=R11U152_CLSPANOFILE_OFF [pkgLeafPatLocByWriting152]=R11U152_PKGLEAFLOC_OFF
 [classVarInitNewDecl152v]=R11V152_CLSVARNEW_OFF )
GW=${GW:-/tmp/v11u152_g}; export GW
for c in $(find $R -name dut.sv | sort); do
  cd=$(dirname $c); rel=$(echo $cd | sed "s#.*/cases/##; s#.*/v11u152_cases/##")
  law=$(head -1 $c | sed -n 's#^// § \([A-Za-z0-9_]*\).*#\1#p'); sw=${SW[$law]:-NOSW}
  v() { /tmp/v11u152_drv/case.sh $cd "$@" | sed 's/^[^ ]* [^ ]* //; s/ md5=.*//; s/cmplines=//'; }
  vp=$(v $P pris); vl=$(v $L law); vo=$(v $L off R11U152_OFF=1); vs=$(v $L sw $sw=1)
  w=$GW/$rel
  ob=$(cmp -s $w/pris.uhdm $w/off.uhdm && echo SAME || echo DIFF)
  lb=$(cmp -s $w/pris.uhdm $w/law.uhdm && echo SAME || echo MOVED)
  sb=$(cmp -s $w/pris.uhdm $w/sw.uhdm && echo SAME || echo DIFF)
  echo "$rel $law | P: $vp | L: $vl | law_bytes=$lb off_bytes=$ob sw_bytes=$sb"
done
