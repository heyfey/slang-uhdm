#!/bin/bash
# grid406.sh <pristine binary> <law binary> <work dir> [case-glob]
# One line per case: case | pristine rc + verdict | law rc + verdict | laws fired (trace) |
# R11U406_OFF bytes vs pristine | the fired laws' switches together vs pristine | the case's own switch vs law.
# The verdict is uhdm-cmp (0 = equal) then uhdm-strictcmp's last line, both against Surelog's golden
# (Surelog: -parse -sverilog, --top-module top when the case declares a module top; slang-uhdm the same top).
set -u
source /tmp/r11u406_env.sh
P=$1; L=$2; W=$3; G=${4:-*/*}
HERE=$(cd "$(dirname "$0")/.." && pwd); SC=/tmp/wt_r11u406/build/uhdm-strictcmp
declare -A SW=(
 [deferredAssertItemDropped406]=R11U406_DEFERREDASSERT_OFF [unitAssocTdMultiDim406]=R11U406_TDMULTIDIM_OFF
 [assocIdxParamBoundTs406]=R11U406_ASSOCIDXPARAM_OFF [modAssocMarkerFullName406]=R11U406_MODMARKERNAME_OFF
 [aliasElemDynTd406]=R11U406_ALIASELEMDYN_OFF [timeModVarIsNet406]=R11U406_TIMENET_OFF
 [timeTsKeywordSpan406]=R11U406_TIMESPAN_OFF [sequenceDeclListed406]=R11U406_SEQDECL_OFF
 [seqConcatNestsRight406]=R11U406_SEQNEST_OFF [arrElemVarKind406]=R11U406_ARRELEMKIND_OFF
 [boundedQueueVarStatic406]=R11U406_BOUNDEDQ_OFF )
for d in $(cd $HERE/cases && ls -d $G/ | sort); do
  d=${d%/}; c=$HERE/cases/$d; w=$W/$d; mkdir -p $w
  T=""; grep -q '^module top\b' $c/dut.sv && T=top
  [ -f $w/g/slpp_all/surelog.uhdm ] || (cd $w && $SURELOG -parse -sverilog -nonote -noinfo -nowarning ${T:+--top-module $T} -mt 0 -mp 0 -o g $c/dut.sv > sl.log 2>&1)
  verdict() { local o=$1; [ -f $o ] || { echo "nodb"; return; }; $UHDM_CMP $w/g/slpp_all/surelog.uhdm $o >/dev/null 2>&1; local r=$?; echo "cmp=$r $($SC $w/g/slpp_all/surelog.uhdm $o 2>&1 | tail -1 | awk '{print $1, $2}')"; }
  rm -rf $w/p.uhdm $w/l.uhdm $w/o.uhdm $w/f.uhdm $w/s.uhdm $w/tr; mkdir -p $w/tr
  (cd $w && $P ${T:+--top $T} $c/dut.sv --single-unit -o $w/p.uhdm > p.log 2>&1); rp=$?
  (cd $w && R11U406_TRACE=$w/tr $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/l.uhdm > l.log 2>&1); rl=$?
  (cd $w && R11U406_OFF=1 $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/o.uhdm > o.log 2>&1); ro=$?
  fired=$(cat $w/tr/* 2>/dev/null | tail -n +2 | grep -v '^OUT' | awk '{print $1}' | sort -u | paste -sd,)
  env406=""; for f in ${fired//,/ }; do env406="$env406 ${SW[$f]:-}=1"; done
  (cd $w && env $env406 $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/f.uhdm > f.log 2>&1)
  own=$(head -1 $c/dut.sv | sed 's#^// § ##'); osw=${SW[$own]:-NONE}
  (cd $w && env $osw=1 $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/s.uhdm > s.log 2>&1)
  off=$(cmp -s $w/p.uhdm $w/o.uhdm && echo same || echo DIFF)
  fset=$(cmp -s $w/p.uhdm $w/f.uhdm && echo same || echo DIFF)
  ownm=$(cmp -s $w/l.uhdm $w/s.uhdm && echo inert || echo moves)
  echo "$d | pris rc=$rp $(verdict $w/p.uhdm) | law rc=$rl $(verdict $w/l.uhdm) | fired=${fired:-none} | OFF=$off fired-set=$fset own($osw)=$ownm"
done
