#!/bin/bash
# sw.sh <law bin> <repro dir>: per law switch, each case naming the law, verdict with that switch alone set
L=$1; R=$2
for sw in HPPSBOUND:hpPartSelBoundNamesBySelect154 HPELEMNAME:hpElemSelNameIsPathSoFar154 GSPROCPS:genScopeProcPsNamedByScope154 GSFOLDTS:genProcFoldTsKeepsScope154 MARGNAME:builtinMethodArgNamedByPath154 VARINITDEF:varInitStrMethodArgDefNet154 CASTREF:elabCastSharesDeclRef154 LVIDXREAD:lvIdxPathIsRead154 LVBASEMEM:lvPathBaseAtFirstMember154 LVSELNAME:lvPathSelNamedByChain154 LVBSSPAN:lvIfacePathBitSelWhole154 DEFPKGTS:defPkgStructParamMemberNames154 PSBOUNDPATH:psBoundPathFirstMember154 PVNESTTS:portViewNestedPatTsNamed154 PIUNPACKED:paramInitUnpackedMemberPath154; do
  s=${sw%%:*}; law=${sw#*:}
  for f in $(grep -l "^// § $law" $(find $R -name dut.sv) 2>/dev/null | sort); do d=$(dirname $f)
    off=$(export R11U154_${s}_OFF=1; VCTAG=off$s /tmp/v11u154_vc.sh $d $L | awk -F'|' '{print $2}')
    echo "$s $(basename $(dirname $d))/$(basename $d) off:$off"
  done
done
