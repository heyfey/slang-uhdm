#!/bin/bash
# sw.sh: per case, law binary under R11U403_OFF=1 and under its group's switches vs pristine (bytes + rc)
. /tmp/v11u403_scr/env.sh
declare -A SW=([FE]=R11U403_FEUNITIMP_OFF [PC]=R11U403_PATCASE_OFF [PM]="R11U403_MATCHOP_OFF R11U403_PATVARNET_OFF" [PV]="R11U403_MATCHOP_OFF R11U403_PATVARNET_OFF" [ML]=R11U403_MACROLITTOK_OFF [UF]=R11U403_UNITFWDCALL_OFF [EV]="R11U403_EVNET_OFF R11U403_EVWAITSPAN_OFF" [FD]=R11U403_DOTPROPROOT_OFF [HO]=R11U403_HOISTORDER_OFF [OM]=R11U403_PKGTFMACRO_OFF [SZ]=R11U403_SIZETICKSP_OFF [UQ]=R11U403_UNIQUE0IF_OFF [AT]=R11U403_OPATTR_OFF [SR]=R11U403_STDRAND_OFF
 [VA]=R11U403_OPATTR_OFF [VC]=R11U403_PATCASE_OFF [VP]=R11U403_PATCASE_OFF [VD]=R11U403_DOTPROPROOT_OFF [VE]="R11U403_EVNET_OFF R11U403_EVWAITSPAN_OFF" [VF]=R11U403_UNITFWDCALL_OFF [VI]=R11U403_FEUNITIMP_OFF [VL]=R11U403_MACROLITTOK_OFF [VM]="R11U403_MATCHOP_OFF R11U403_PATVARNET_OFF" [VO]=R11U403_PKGTFMACRO_OFF [VQ]=R11U403_UNIQUE0IF_OFF [VS]=R11U403_STDRAND_OFF [VZ]=R11U403_SIZETICKSP_OFF [VH]=R11U403_HOISTORDER_OFF)
n=0; a=0; b=0; T=/tmp/v11u403_scr/sw; mkdir -p $T
for root in "$@"; do for d in $(find $root -name dut.sv | sort); do c=$(dirname $d); g=$(basename $(dirname $c)); n=$((n+1))
  env=""; for s in ${SW[$g]}; do env="$env $s=1"; done
  rm -f $T/p.uhdm $T/a.uhdm $T/b.uhdm
  (cd $c; $PRIS dut.sv --single-unit --nobuiltin -o $T/p.uhdm >/dev/null 2>&1; echo $? > $T/p.rc
   env R11U403_OFF=1 $LAW dut.sv --single-unit --nobuiltin -o $T/a.uhdm >/dev/null 2>&1; echo $? > $T/a.rc
   env $env $LAW dut.sv --single-unit --nobuiltin -o $T/b.uhdm >/dev/null 2>&1; echo $? > $T/b.rc)
  if cmp -s $T/p.uhdm $T/a.uhdm && cmp -s $T/p.rc $T/a.rc; then a=$((a+1)); else echo "MOVES-UNDER-R11U403_OFF $g/$(basename $c)"; fi
  if cmp -s $T/p.uhdm $T/b.uhdm && cmp -s $T/p.rc $T/b.rc; then b=$((b+1)); else echo "MOVES-UNDER-OWN-SWITCH $g/$(basename $c) [$env]"; fi
done; done
echo "R11U403_OFF restores pristine bytes+rc: $a of $n; own switch(es): $b of $n"
