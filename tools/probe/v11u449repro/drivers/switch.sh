#!/bin/bash
# per-law switch check on ver1: for every case, each firing law's own switch alone; report md5 vs pristine
declare -A SW=( [macroCloneLoopVarPerSub449]=R11U449_LVKEYSUB_OFF [pkgVarArrCloneLoopVarTs449]=R11U449_PKGVARARR_OFF [formalClsElemMemberDrill449]=R11U449_FORMALCLSMEM_OFF [cloneLvFormalTdTopListing449]=R11U449_FORMALTDTOP_OFF [freeCloneCmCallKeepsClassMethod449]=R11U449_FREECLONECM_OFF [cloneCtorEatenLocalNoBind449]=R11U449_CTOREATEN_OFF [drillUnresolvedFallback449v]=R11V449_DRILLFALL_OFF [pkgVarScopedNameInt449v]=R11V449_PKGVARSCOPED_OFF )
for R in /tmp/v11u449_cases /tmp/v11u449_cases_impl; do
for d in $(cd $R && ls -d */* | sort); do
  k=$(echo $d|tr / _); [ $R = /tmp/v11u449_cases_impl ] && k=_tmp_v11u449_cases_impl_$k
  tr=/tmp/v11u449_tr/v1_$(echo $d|tr / _); laws=$(cat $tr/* 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort -u)
  [ -z "$laws" ] && continue
  pm=$(md5sum < /tmp/v11u449_scr/out/$k/pris/ours.uhdm | cut -c1-8); lm=$(md5sum < /tmp/v11u449_scr/out/$k/law/ours.uhdm | cut -c1-8); vm=$(md5sum < /tmp/v11u449_scr/out/$k/ver1/ours.uhdm | cut -c1-8)
  line="$k pris=$pm law=$lm ver=$vm"
  env1=(); for L in $laws; do s=${SW[$L]}; env1+=("$s=1"); m=$(nice -n 19 bash /tmp/v11u449_run1.sh $R/$d /tmp/v11u449_bin/ver1 sw "$s=1" | awk '{print $NF}' | sed 's/md5=//'); line="$line $s:$m"; done
  m=$(nice -n 19 bash /tmp/v11u449_run1.sh $R/$d /tmp/v11u449_bin/ver1 swall "${env1[@]}" | awk '{print $NF}' | sed 's/md5=//'); echo "$line ALL:$m"
done; done
