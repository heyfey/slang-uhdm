#!/bin/bash
# v11u206: per-switch droppability: trace firings of the law binary, then each switch alone; print cases whose bytes move vs law and whether the law traced there
. /tmp/v11u206_drv/env.sh || exit 3
cd /tmp/v11u206_allcases; O=/tmp/v11u206_sw; rm -rf $O; mkdir -p $O
declare -A LAW=([R11U206_TPCASTDEF_OFF]=tpCastUseBindsDefDefault206 [R11U206_TPARRELEM_OFF]=tpArrayElemBindsDefDefault206 [R11U206_UTIFCPRG_OFF]=unitClassTdEndAtInitIfcPrg206 [R11U206_CLSCOPETDRET_OFF]=classScopeTdRetBuildsOwner206 [R11U206_GENCLSVAR_OFF]=genScopeClassVarListed206 [R11U206_GENCLSSPAN_OFF]=genScopeClassVarSpecAtName206)
while read c; do k=$(echo $c | tr / _); mkdir -p $O/tr/$k; (cd $c && R11U206_TRACE=$O/tr/$k $VB/law.bin dut.sv --single-unit --nobuiltin -o $O/$k.law.uhdm >/dev/null 2>&1); done < list.txt
for sw in "${!LAW[@]}"; do mv=0; untr=0; while read c; do k=$(echo $c | tr / _); (cd $c && env $sw=1 $VB/law.bin dut.sv --single-unit --nobuiltin -o $O/$k.sw.uhdm >/dev/null 2>&1); if ! cmp -s $O/$k.law.uhdm $O/$k.sw.uhdm; then mv=$((mv+1)); cat $O/tr/$k/*.206 2>/dev/null | grep -q "^${LAW[$sw]} " || { untr=$((untr+1)); echo "  UNTRACED $sw $c"; }; fi; rm -f $O/$k.sw.uhdm; done < list.txt; echo "$sw moved=$mv untraced=$untr"; done
