#!/bin/bash
# grid.sh <law binary> <pristine binary>: one line per case dir (explicit dirs under cases/<GROUP>/):
#   case | pristine reading | law reading | R11U420_OFF == pristine | the case's own law switch == pristine
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2
declare -A SW=( [pkgLateTsNetCapture420]=R11U420_FOREACHNETCAP_OFF [pkgLateTsLoopVarCapture420]=R11U420_LOOPVARCAP_OFF
  [unitVarNetSourceOrder420]=R11U420_UNITVARORDER_OFF [contAssignVarInitRhsShared420]=R11U420_CAVARINIT_OFF
  [contAssignVarInitRhsDropped420]=R11U420_CAVARINIT_OFF
  [seqAndOrLogOp420]=R11U420_SEQANDOR_OFF [seqAndOrParenOperand420]=R11U420_SEQANDOR_OFF
  [assertBinParenSpanInner420]=R11U420_ASSERTBINPAREN_OFF [propAndOrUnparented420]=R11U420_PROPANDOR_OFF
  [seqLeadDelayPairUnary420]=R11U420_SEQLEADPAIR_OFF [seqLeadDelayUnary420]=R11U420_SEQLEADPAIR_OFF
  [clockedSeqEventSpanBare420]=R11U420_CLOCKEDSEQ_OFF [ansiNoDirPort420]=R11U420_ANSINODIR_OFF
  [ansiNoDirNetPortUntyped420]=R11U420_ANSINODIR_OFF [unpackedStructVarPosInit420]=R11U420_USTRUCTPOSINIT_OFF
  [unpackedStructVarInitIsVar420]=R11U420_USTRUCTPOSINIT_OFF [arrayBcastConcatActual420]=R11U420_ARRCONCAT_OFF [modOutOfBodyMethodIsModuleTf420]=R11U420_MODOOBMETHOD_OFF )
O=/tmp/r11u420_scr/out
for c in $(find $R/cases -mindepth 2 -maxdepth 2 -type d | sort); do
  [ -f $c/dut.sv ] || continue
  g=$(basename $(dirname $c)); n=$(basename $c); key=${g}_$n
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||'); sw=${SW[$law]}
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U420_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s $sw=1 >/dev/null
  mp=$(md5sum < $O/$key/p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $O/$key/o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $O/$key/s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $O/$key/o/rc); rs=$(cat $O/$key/s/rc); rp=$(cat $O/$key/p/rc)
  echo "$g/$n | $law | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
