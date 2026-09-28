#!/bin/bash
# r11u201: each law's own switch, alone, on its own grid: the law binary with R11U201_<LAW>_OFF=1 must write the
# pristine bytes on every case of the law's grid where no other law of the pass fires (the trace names the laws
# that fired; a case where another fires too is listed as mixed).  Both forms (parse; ELAB=1 for -elabuhdm).
# usage: switchcheck.sh [law binary name in $B, default law.bin]      (uses case.sh; fence fail-closed there)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
C=$HERE/../cases; LB=${1:-law.bin}
for pair in C:R11U201_CLSBOUND_OFF:clsScopedBoundWholeSpan201 S:R11U201_SYSARG_OFF:sysCtxRefArgBare201 \
            Q:R11U201_OPARG_OFF:opCtxRefArgBare201 Q:R11U201_NONRED_OFF:nonReduceOpArgBare201 \
            M:R11U201_MARGNEST_OFF:methodArgNestedRefChain201 Z:R11U200_NEWARRHP_OFF:newArrayArgPathElemsStripped200 \
            Z:R11U200_FOLDDEPTH_OFF:unitBoundFoldAtLeftOperand200_depth Z:R11U200_UNITFOLD_OFF:unitBoundFoldAtLeftOperand200_unit \
            Z:R11U200_GENBITS_OFF:genBlockBitsKeepsSelect200 N:R11U201_SELIDXCALL_OFF:callArgInSelIdxChainName201; do
  IFS=: read g sw law <<< "$pair"
  for form in parse elab; do
    same=0; n=0; mixed=""; bad=""; fired=0
    E=; [ $form = elab ] && E=1
    for d in $(find $C/$g -name dut.sv -printf '%h\n' | sort); do
      r=${d#$C/}; P=/tmp/r11u201_sw/$form/pris/$r; L=/tmp/r11u201_sw/$form/$sw/$r; T=/tmp/r11u201_sw/$form/tr/$r
      [ -s $P/ours.uhdm ] || ELAB=$E SLANG_UHDM=$B/pris.bin bash $HERE/case.sh $d $P > /dev/null 2>&1
      rm -rf $T; mkdir -p $T
      ELAB=$E R11U201_TRACE=$T R11U200_TRACE=$T SLANG_UHDM=$B/$LB bash $HERE/case.sh $d /tmp/r11u201_sw/$form/law/$r > /dev/null 2>&1
      laws=$(cat $T/*.T201 $T/*.200E $T/*.200P 2>/dev/null | sed -E 's/^(unitBoundFoldAtLeftOperand200) (depth|unit).*/\1_\2/; s/ .*//' | grep -v '^OUT' | sort -u | tr '\n' ' ')
      grep -q "$law" <<< "$laws" || continue
      fired=$((fired+1)); n=$((n+1))
      others=$(echo $laws | tr ' ' '\n' | grep -v "^$law\$" | grep -c .)
      ELAB=$E env $sw=1 SLANG_UHDM=$B/$LB bash $HERE/case.sh $d $L > /dev/null 2>&1
      if [ "$others" -gt 0 ]; then mixed="$mixed $r"; continue; fi
      if cmp -s $L/ours.uhdm $P/ours.uhdm; then same=$((same+1)); else bad="$bad $r"; fi
    done
    echo "$sw form=$form grid=$g fired=$fired restored=$same mixed:${mixed:- none} NOT_RESTORED:${bad:- none}"
  done
done
