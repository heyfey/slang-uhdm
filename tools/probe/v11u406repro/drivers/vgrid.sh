#!/bin/bash
# vgrid.sh <casesroot> <work> [glob]: law vs verified bytes; R11V406_OFF on verified vs law; verified verdict
source /tmp/v11u406_env.sh
R=$1; W=$2; G=${3:-*/*}; SC=/tmp/wt_v11u406/build/uhdm-strictcmp
L=/tmp/v11u406_bin/law.bin; V=/tmp/v11u406_bin/ver4.bin
for d in $(cd $R && ls -d $G/ | sort); do
  d=${d%/}; c=$R/$d; w=$W/$d; mkdir -p $w
  T=""; grep -q '^module top\b' $c/dut.sv && T=top
  [ -f $w/g/slpp_all/surelog.uhdm ] || (cd $w && $SURELOG -parse -sverilog -nonote -noinfo -nowarning ${T:+--top-module $T} -mt 0 -mp 0 -o g $c/dut.sv > sl.log 2>&1)
  rm -rf $w/vl.uhdm $w/vv.uhdm $w/vo.uhdm $w/vs.uhdm $w/vtr; mkdir -p $w/vtr
  (cd $w && $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/vl.uhdm > vl.log 2>&1); rl=$?
  (cd $w && R11U406_TRACE=$w/vtr $V ${T:+--top $T} $c/dut.sv --single-unit -o $w/vv.uhdm > vv.log 2>&1); rv=$?
  (cd $w && R11V406_OFF=1 $V ${T:+--top $T} $c/dut.sv --single-unit -o $w/vo.uhdm > vo.log 2>&1)
  (cd $w && R11V406_TIMEKW_OFF=1 R11V406_SEQLEAD_OFF=1 R11V406_SEQRANGE_OFF=1 $V ${T:+--top $T} $c/dut.sv --single-unit -o $w/vs.uhdm > vs.log 2>&1)
  fv=$(cat $w/vtr/* 2>/dev/null | grep -cE "timeNetKeywordOnly406v|seqNestLeadingDelay406v|seqNestRangedDelay406v")
  vl=$(cmp -s $w/vl.uhdm $w/vv.uhdm && echo same || echo MOVED)
  vo=$(cmp -s $w/vl.uhdm $w/vo.uhdm && echo same || echo DIFF)
  vs=$(cmp -s $w/vl.uhdm $w/vs.uhdm && echo same || echo DIFF)
  ver="nodb"; [ -f $w/vv.uhdm ] && { $UHDM_CMP $w/g/slpp_all/surelog.uhdm $w/vv.uhdm >/dev/null 2>&1; ver="cmp=$? $($SC $w/g/slpp_all/surelog.uhdm $w/vv.uhdm 2>&1 | tail -1 | awk '{print $1,$2}')"; }
  echo "$d | law rc=$rl | ver rc=$rv $ver | ver-vs-law=$vl fix-fired=$fv | R11V406_OFF=$vo ALLFIX_OFF=$vs"
done
