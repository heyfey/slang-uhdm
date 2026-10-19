#!/bin/bash
# grid.sh <law binary> <pristine binary> : one line per case dir:
#   case | pristine reading | law reading | R11U412_OFF == pristine | own switch == pristine
# MB and AC run with the builtin classes on both sides (run1b.sh), the rest with -nobuiltin.
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2
declare -A SW=( [BS]=R11U412_BITSIGNED_OFF [WI]=R11U412_WILDCARDIDX_OFF [EP]=R11U412_EXTSCOPEDPARAM_OFF
  [UP]=R11U412_UNITLITFOLD_OFF [US]=R11U412_UNPSTRUCTELEM_OFF [OR]=R11U412_CLSTDRETLOC_OFF
  [MB]=R11U412_MAILBOXSPEC_OFF [ER]=R11U412_ENUMRANGED_OFF [NT]=R11U412_MODNETTYPE_OFF
  [TB]=R11U412_DECLONLYBODY_OFF [GI]=R11U412_GENPOSNODBL_OFF [VI]=R11U412_VARSYSCALL_OFF
  [CP]=R11U412_CLSKWPARAMLAST_OFF [PL]=R11U412_PROPLOCALVAR_OFF [AC]=R11U412_ASSOCCLASSIDX_OFF
  [TP]=R11U412_KWLESSTP_OFF [IC]=R11U412_INTERCONNECT_OFF [IF]=R11U412_IMPFNNAME_OFF
  [UD]=R11U412_UDPSTAR_OFF )
for c in $(ls -d $R/cases/*/* | sort); do
  g=$(basename $(dirname $c)); n=$(basename $c); bi=0; run=run1.sh
  case $g in MB|AC) bi=1; run=run1b.sh;; esac
  sw=${SW[$g]}
  case $n in or05) sw=R11U412_RETALIASTWIN_OFF;; or01|or02|or03) sw=R11U412_OOBSCOPEDRET_OFF;; er07) sw=R11U412_ENUMXZREPL_OFF;; ud02) sw=R11U412_UDPINITTICK_OFF;; esac
  p=$(bash $R/drivers/$run $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/$run $c $L l | cut -d' ' -f2-)
  bash $R/drivers/offrun.sh $c $L o $bi R11U412_OFF=1
  bash $R/drivers/offrun.sh $c $L s $bi $sw=1
  mp=$(md5sum < $c/out_p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $c/out_o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $c/out_s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $c/out_o/rc); rs=$(cat $c/out_s/rc); rp=$(cat $c/out_p/rc)
  echo "$g/$n | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
