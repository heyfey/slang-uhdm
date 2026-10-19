R=/tmp/wt_r11u403/tools/probe/r11u403repro/cases
declare -A SW=([FE]=R11U403_FEUNITIMP_OFF [PC]=R11U403_PATCASE_OFF [PM]="R11U403_MATCHOP_OFF R11U403_PATVARNET_OFF" [PV]="R11U403_MATCHOP_OFF R11U403_PATVARNET_OFF" [ML]=R11U403_MACROLITTOK_OFF [UF]=R11U403_UNITFWDCALL_OFF [EV]="R11U403_EVNET_OFF R11U403_EVWAITSPAN_OFF" [FD]=R11U403_DOTPROPROOT_OFF [HO]=R11U403_HOISTORDER_OFF [OM]=R11U403_PKGTFMACRO_OFF [SZ]=R11U403_SIZETICKSP_OFF [UQ]=R11U403_UNIQUE0IF_OFF [AT]=R11U403_OPATTR_OFF [SR]=R11U403_STDRAND_OFF)
n=0; ok=0
for d in $(find $R -name dut.sv | sort); do c=$(dirname $d); g=$(basename $(dirname $c)); n=$((n+1))
  env=""; for s in ${SW[$g]}; do env="$env $s=1"; done
  (cd $c; /tmp/r11u403_pristine.bin dut.sv --single-unit --nobuiltin -o /tmp/r11u403_scr/sw_p.uhdm >/dev/null 2>&1; echo $? > /tmp/r11u403_scr/sw_p.rc; env $env ${LAWBIN:-/tmp/r11u403_law10.bin} dut.sv --single-unit --nobuiltin -o /tmp/r11u403_scr/sw_l.uhdm >/dev/null 2>&1; echo $? > /tmp/r11u403_scr/sw_l.rc)
  if cmp -s sw_p.uhdm sw_l.uhdm && cmp -s sw_p.rc sw_l.rc; then ok=$((ok+1)); else echo "MOVES-UNDER-OWN-SWITCH $g/$(basename $c) [$env]"; fi; rm -f sw_p.uhdm sw_l.uhdm
done; echo "own switch(es) restore pristine bytes+rc: $ok of $n"
