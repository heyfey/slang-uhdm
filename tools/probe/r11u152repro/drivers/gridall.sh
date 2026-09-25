#!/bin/bash
# gridall.sh: every case under cases/ with the pristine binary, the law binary, the law binary with
# R11U152_OFF=1 (must be byte-identical to pristine) and the law binary with the case's OWN law
# switch (named by the case's first line `// § <law>`, mapped below).  Prints one line per case:
#   <case> <law> pris=<verdict> law=<verdict> sw=<verdict> off_bytes=<SAME|DIFF> sw_bytes=<SAME|DIFF>
# Goldens: drivers/grid.sh (pinned Surelog, check_probe's arguments), under $GW (default /tmp/r11u152_g).
D=$(cd $(dirname $0)/.. && pwd)
P=${PRIS:-/tmp/r11u152_bin/pris.bin}; L=${LAW:-/tmp/r11u152_bin/law2.bin}
declare -A SW=(
 [portConnParamFoldAtActual152]=R11U152_C3_OFF
 [genLpOperandTsNoParent152]=R11U152_GENLPOPTS_OFF
 [crossPkgFoldTsNameOnChain152]=R11U152_FOLDCHAIN_OFF
 [tpElemPatAtUser152]=R11U152_TPELEMPAT_OFF
 [pkgElemMemberPatNoLoc152]=R11U152_PKGELEMPAT_OFF
 [packedElemAliasTypedef152]=R11U152_ELEMALIAS_OFF
 [tpOvrTypedefStructSpan152]=R11U152_TPOVRSTRUCT_OFF
 [genCaseItemUnnamed152]=R11U152_GENCASE_OFF
 [delayLiteralValueText152]=R11U152_DLYREAL_OFF
 [unsupportedTsInitEnd152]=R11U152_CGINITEND_OFF
 [classVarInitSpan152]=R11U152_CLSVARINIT_OFF
 [classSpecNestedAtName152]=R11U152_CLSNESTNAME_OFF
 [classSpecPaNoFile152]=R11U152_CLSPANOFILE_OFF
 [pkgLeafPatLocByWriting152]=R11U152_PKGLEAFLOC_OFF
)
GW=${GW:-/tmp/r11u152_g}
for c in $(find $D/cases -name dut.sv | sort); do
  cd=$(dirname $c); rel=${cd#$D/cases/}
  law=$(head -1 $c | sed -n 's#^// § \([A-Za-z0-9_]*\).*#\1#p'); sw=${SW[$law]}
  [ -n "$sw" ] || { echo "$rel NO-LAW-SWITCH ($law)"; continue; }
  v() { $D/drivers/grid.sh $cd "$@" | sed 's/.* strict=//; s/ rc=.*//'; }
  vp=$(v $P pris); vl=$(v $L law); vo=$(v $L off R11U152_OFF=1); vs=$(v $L sw $sw=1)
  w=$GW/$rel
  ob=$(cmp -s $w/pris.uhdm $w/off.uhdm && echo SAME || echo DIFF)
  sb=$(cmp -s $w/pris.uhdm $w/sw.uhdm && echo SAME || echo DIFF)
  echo "$rel $law pris=$vp law=$vl sw=$vs off_bytes=$ob sw_bytes=$sb"
done
