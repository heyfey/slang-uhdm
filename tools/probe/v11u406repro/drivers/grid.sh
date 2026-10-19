#!/bin/bash
# grid.sh <pristine> <law> <work> <casesroot> [glob]
source /tmp/v11u406_env.sh
P=$1; L=$2; W=$3; R=$4; G=${5:-*/*}
SC=${SC:-/tmp/wt_v11u406/build/uhdm-strictcmp}
declare -A SW=(
 [deferredAssertItemDropped406]=R11U406_DEFERREDASSERT_OFF [unitAssocTdMultiDim406]=R11U406_TDMULTIDIM_OFF
 [assocIdxParamBoundTs406]=R11U406_ASSOCIDXPARAM_OFF [modAssocMarkerFullName406]=R11U406_MODMARKERNAME_OFF
 [aliasElemDynTd406]=R11U406_ALIASELEMDYN_OFF [timeModVarIsNet406]=R11U406_TIMENET_OFF
 [timeTsKeywordSpan406]=R11U406_TIMESPAN_OFF [sequenceDeclListed406]=R11U406_SEQDECL_OFF
 [seqConcatNestsRight406]=R11U406_SEQNEST_OFF [arrElemVarKind406]=R11U406_ARRELEMKIND_OFF
 [boundedQueueVarStatic406]=R11U406_BOUNDEDQ_OFF )
dumpn() { [ -f $1 ] || { echo -; return; }; $UHDM_DUMP $1 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//' > $1.dump; diff $w/g.dump $1.dump | grep -c '^[<>]'; }
for d in $(cd $R && ls -d $G/ | sort); do
  d=${d%/}; c=$R/$d; w=$W/$d; mkdir -p $w
  T=""; grep -q '^module top\b' $c/dut.sv && T=top
  [ -f $w/g/slpp_all/surelog.uhdm ] || (cd $w && $SURELOG -parse -sverilog -nonote -noinfo -nowarning ${T:+--top-module $T} -mt 0 -mp 0 -o g $c/dut.sv > sl.log 2>&1)
  [ -f $w/g/slpp_all/surelog.uhdm ] || { echo "$d | NO GOLDEN"; continue; }
  $UHDM_DUMP $w/g/slpp_all/surelog.uhdm 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//' > $w/g.dump
  verdict() { local o=$1; [ -f $o ] || { echo "nodb"; return; }; $UHDM_CMP $w/g/slpp_all/surelog.uhdm $o >/dev/null 2>&1; local r=$?; echo "cmp=$r $($SC $w/g/slpp_all/surelog.uhdm $o 2>&1 | tail -1 | awk '{print $1, $2}')"; }
  rm -rf $w/p.uhdm $w/l.uhdm $w/o.uhdm $w/s.uhdm $w/tr; mkdir -p $w/tr
  (cd $w && $P ${T:+--top $T} $c/dut.sv --single-unit -o $w/p.uhdm > p.log 2>&1); rp=$?
  (cd $w && R11U406_TRACE=$w/tr $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/l.uhdm > l.log 2>&1); rl=$?
  (cd $w && R11U406_OFF=1 $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/o.uhdm > o.log 2>&1)
  fired=$(cat $w/tr/* 2>/dev/null | tail -n +2 | grep -v '^OUT' | awk '{print $1}' | sort -u | paste -sd,)
  own=$(head -1 $c/dut.sv | sed 's#^// § ##'); osw=${SW[$own]:-NONE}
  (cd $w && env $osw=1 $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/s.uhdm > s.log 2>&1)
  off=$(cmp -s $w/p.uhdm $w/o.uhdm && echo same || echo DIFF)
  ownm=$(cmp -s $w/l.uhdm $w/s.uhdm && echo inert || echo moves)
  pl=$(cmp -s $w/p.uhdm $w/l.uhdm && echo bytes=same || echo bytes=moved)
  echo "$d | pris rc=$rp $(verdict $w/p.uhdm) dd=$(dumpn $w/p.uhdm) | law rc=$rl $(verdict $w/l.uhdm) dd=$(dumpn $w/l.uhdm) | $pl | fired=${fired:-none} | OFF=$off own=$ownm"
done
