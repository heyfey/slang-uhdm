#!/bin/bash
# attrib_probe.sh <pristine probe dir> <case key>... (key = rel path with '/' as '__'): per probe byte mover, rerun the
# law binary with R11U164_OFF=1 R11U161_OFF=1 and with each switch alone; print whether landing-off gives the pristine
# bytes and which switches change the law bytes.  (after r11u160repro/drivers/attrib_probe.sh)
P=$1; shift; T=${TMPD:-/tmp/r11u164_pattr}; mkdir -p $T
R=${PROBE_ROOT:-/tmp/wt_r11u164/tests/probe}
SW="R11U164_RANGEQ_OFF R11U164_RANGEQSIZE_OFF R11U164_CADELAY_OFF R11U164_DLYPARAMELAB_OFF R11U164_PVMPDEF_OFF R11U164_PVSHARE_OFF R11U164_SELBASELEAF_OFF R11U164_BINDPATHNAME_OFF R11U164_GENNDAHP_OFF R11U161_ROUTE_OFF R11U161_SPAN_OFF R11U161_NAME_OFF R11U161_PORT_OFF R11U161_ALIAS_OFF R11U161_FILE_OFF"
for k in "$@"; do
  d=$R/$(echo $k | sed 's#__#/#g')
  run() { rm -f $T/o.uhdm; (cd $d && env "$@" $LAW dut.sv --single-unit --nobuiltin -o $T/o.uhdm > /dev/null 2>&1 </dev/null); }
  run; cp $T/o.uhdm $T/law.uhdm
  run R11U164_OFF=1 R11U161_OFF=1; off=$(cmp -s $T/o.uhdm $P/$k.uhdm && echo pristine || echo DIFF)
  c=""; for s in $SW; do run $s=1; cmp -s $T/o.uhdm $T/law.uhdm || c="$c ${s}"; done
  echo "$k | OFF:$off | contributing:${c:- none}"
done
