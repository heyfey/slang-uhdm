#!/bin/bash
# switch404.sh <pristine binary> <law binary> <work dir>
# Per case: the law binary with the case's OWN law switch set (the law named on the case's first line)
# against the pristine binary's bytes, and the same with that switch plus the listed partner switch.
set -u
P=$1; L=$2; W=$3
HERE=$(cd "$(dirname "$0")/.." && pwd)
declare -A SW=(
 [undefaultedDefInvalidInst404]=R11U404_UNDEFPARAMDEF_OFF [invalidCaAssignChild404]=R11U404_CAINVALID_OFF
 [macroArgParamOrder404]=R11U404_MACROARGORDER_OFF [pkgStructMemberSysArgBind404]=R11U404_PKGMEMBERSYSARG_OFF
 [unknownModEmptyNamedConnPort404]=R11U404_UNKEMPTYCONN_OFF [unknownModBitSelConnScope404]=R11U404_UNKBITSELSCOPE_OFF
 [seqMatchItemsDropped404]=R11U404_SEQMATCH_OFF [unitParamXzLiteral404]=R11U404_UNITXZ_OFF
 [assocIdxSpanAtTokens404]=R11U404_ASSOCIDXSPAN_OFF [varInitOpCastKept404]=R11U404_VARINITOP_OFF
 [implicitNetDefLastRef404]=R11U404_IMPNETLASTREF_OFF [subrBuiltinClassArrElemUnsup404]=R11U404_BUILTINCLASSELEM_OFF
 [unknownModWildcardConnPort404]=R11U404_UNKWILDCONN_OFF )
for d in $(cd $HERE/cases && ls -d */*/ | sort); do
  d=${d%/}; c=$HERE/cases/$d; w=$W/$d; mkdir -p $w
  law=$(head -1 $c/dut.sv | sed 's#^// § ##'); sw=${SW[$law]:-NONE}
  T=""; grep -q '^module top\b' $c/dut.sv && T=top
  rm -f $w/p.uhdm $w/s.uhdm $w/l.uhdm
  (cd $w && $P ${T:+--top $T} $c/dut.sv --single-unit -o $w/p.uhdm > /dev/null 2>&1)
  (cd $w && $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/l.uhdm > /dev/null 2>&1)
  (cd $w && env $sw=1 $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/s.uhdm > /dev/null 2>&1); rs=$?
  moved=$(cmp -s $w/p.uhdm $w/l.uhdm && echo unmoved || echo moved)
  own=$(cmp -s $w/p.uhdm $w/s.uhdm && echo pristine || echo DIFF)
  echo "$d | $law | $moved | $sw -> $own (rc=$rs)"
done
