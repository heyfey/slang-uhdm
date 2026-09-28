#!/bin/bash
# switchcheck.sh <bin> case... : per case (both forms), the laws that fire (trace); for a case where ONE law (or one law +
# its refinement) fires, that law's switch alone must restore pristine bytes; R11U201_OFF+R11U200_OFF must restore all.
. "$(cd "$(dirname "$0")" && pwd)/env.sh" || exit 3
B=$VB/$1; shift
sw() { case $1 in
  newArrayArgPathElemsStripped200|newArrayKeepFrozenBare201v) echo R11U200_NEWARRHP_OFF;;
  unitBoundFoldAtLeftOperand200) echo "$2";;
  genBlockBitsKeepsSelect200) echo R11U200_GENBITS_OFF;;
  clsScopedBoundWholeSpan201|clsScopedBoundPlainClass201v) echo R11U201_CLSBOUND_OFF;;
  sysCtxRefArgBare201) echo R11U201_SYSARG_OFF;;
  opCtxRefArgBare201|opCtxBindableTarget201v) echo R11U201_OPARG_OFF;;
  nonReduceOpArgBare201) echo R11U201_NONRED_OFF;;
  methodArgNestedRefChain201) echo R11U201_MARGNEST_OFF;;
  callArgInSelIdxChainName201) echo R11U201_SELIDXCALL_OFF;;
  *) echo "?$1";; esac; }
T=/tmp/v11u201_sc; mkdir -p $T
for c in "$@"; do for E in "" --elabuhdm; do
  rm -rf $T/tr $T/p.uhdm $T/l.uhdm $T/o.uhdm $T/s.uhdm; mkdir -p $T/tr; ( cd $c; $VB/pris.bin dut.sv --single-unit --nobuiltin $E -o $T/p.uhdm >/dev/null 2>&1; R11U201_TRACE=$T/tr R11U200_TRACE=$T/tr $B dut.sv --single-unit --nobuiltin $E -o $T/l.uhdm >/dev/null 2>&1 )
  laws=$(cat $T/tr/* 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort -u | tr "\n" " " | sed "s/ *$//")
  [ -z "$laws" ] && continue
  rm -f $T/o.uhdm; ( cd $c; R11U201_OFF=1 R11U200_OFF=1 $B dut.sv --single-unit --nobuiltin $E -o $T/o.uhdm >/dev/null 2>&1 ); off=$(cmp -s $T/p.uhdm $T/o.uhdm && echo OFF=pristine || echo OFF=NOT_RESTORED)
  moved=$(cmp -s $T/p.uhdm $T/l.uhdm && echo nomove || echo moved)
  swset=$(for l in $laws; do d=""; [ "$l" = unitBoundFoldAtLeftOperand200 ] && d=$(grep -h '^unitBound' $T/tr/* | awk '{print ($2=="unit")?"R11U200_UNITFOLD_OFF":"R11U200_FOLDDEPTH_OFF"}' | sort -u | tr '\n' ' '); for x in $(sw $l "$d"); do echo $x; done; done | sort -u | tr "\n" " " | sed "s/ *$//")
  one=""; if [ $(echo $swset | wc -w) = 1 ] && [ $moved = moved ]; then rm -f $T/s.uhdm; ( cd $c; env $swset=1 $B dut.sv --single-unit --nobuiltin $E -o $T/s.uhdm >/dev/null 2>&1 ); one=$(cmp -s $T/p.uhdm $T/s.uhdm && echo "$swset:restored" || echo "$swset:NOT_RESTORED"); elif [ $moved = moved ]; then one="mixed($swset)"; fi
  echo "$(echo $c | sed 's#.*/cases/##; s#.*/tools/probe/##')${E:+ elab}	$moved	$off	$one	$laws"
done; done
