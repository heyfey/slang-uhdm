#!/bin/bash
# switches.sh <law bin>: per law switch, the cases naming that law read under the switch (must revert to pristine's verdict)
D=$(cd "$(dirname "$0")" && pwd); R=$(dirname $D); L=$1
source /tmp/r11u154_env.sh
for sw in HPPSBOUND:hpPartSelBoundNamesBySelect154 HPELEMNAME:hpElemSelNameIsPathSoFar154 GSPROCPS:genScopeProcPsNamedByScope154 GSFOLDTS:genProcFoldTsKeepsScope154 MARGNAME:builtinMethodArgNamedByPath154 VARINITDEF:varInitStrMethodArgDefNet154 CASTREF:elabCastSharesDeclRef154 LVIDXREAD:lvIdxPathIsRead154 LVBASEMEM:lvPathBaseAtFirstMember154 LVSELNAME:lvPathSelNamedByChain154 LVBSSPAN:lvIfacePathBitSelWhole154 DEFPKGTS:defPkgStructParamMemberNames154 PSBOUNDPATH:psBoundPathFirstMember154 PVNESTTS:portViewNestedPatTsNamed154 PIUNPACKED:paramInitUnpackedMemberPath154; do
  s=${sw%%:*}; law=${sw#*:}
  for f in $(grep -l "^// § $law\$" $(find $R -name dut.sv) 2>/dev/null); do d=$(dirname $f)
    on=$(MAX=1 bash $D/rc.sh $d $L | sed 's/^[^ ]* [^ ]* //'); off=$(export R11U154_${s}_OFF=1; MAX=1 bash $D/rc.sh $d $L | sed 's/^[^ ]* [^ ]* //')
    printf '%-12s %-26s on: %-40s off: %s\n' $s "$(basename $(dirname $d))/$(basename $d)" "$on" "$off"
  done
done
