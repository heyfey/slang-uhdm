#!/bin/bash
# offcheck.sh <out.tsv> <case dir>...: for every case (a dut.sv dir) export with the pristine binary, the law binary,
# the law binary under R11U164_OFF=1 R11U161_OFF=1 (whole landing off) and under each switch alone; print per case
# whether the landing-off bytes equal pristine, whether law moved, and which switches change the law bytes.
# Scratch under /tmp/r11u164_off (never the case dir).  Cases only (no corpus source is read here).
O=$1; shift; T=/tmp/r11u164_off; mkdir -p $T
SW="R11U164_RANGEQ_OFF R11U164_RANGEQSIZE_OFF R11U164_CADELAY_OFF R11U164_PVMPDEF_OFF R11U164_PVSHARE_OFF R11U164_SELBASELEAF_OFF R11U164_BINDPATHNAME_OFF R11U164_GENNDAHP_OFF R11U164_DLYPARAMELAB_OFF R11U161_ROUTE_OFF R11U161_SPAN_OFF R11U161_NAME_OFF R11U161_PORT_OFF R11U161_ALIAS_OFF R11U161_FILE_OFF ${EXTRA_SW}"
: > $O
for c in "$@"; do
  c=$(realpath $c)
  run() { local b=$1; shift; rm -f $T/o.uhdm; (cd $c && env "$@" $b dut.sv --single-unit --nobuiltin -o $T/o.uhdm > /dev/null 2>&1); echo $?; }
  run $PRIS > /dev/null; cp $T/o.uhdm $T/p.uhdm 2>/dev/null || : > $T/p.uhdm
  run $LAW > /dev/null; cp $T/o.uhdm $T/l.uhdm 2>/dev/null || : > $T/l.uhdm
  moved=$(cmp -s $T/p.uhdm $T/l.uhdm && echo same || echo MOVED)
  run $LAW R11U164_OFF=1 R11U161_OFF=1 > /dev/null; off=$(cmp -s $T/o.uhdm $T/p.uhdm && echo pristine || echo DIFF)
  con=""; for s in $SW; do run $LAW $s=1 >/dev/null; cmp -s $T/o.uhdm $T/l.uhdm || con="$con ${s}"; done
  printf '%s\t%s\toff=%s\t%s\n' "${c#*/tools/probe/}" "$moved" "$off" "${con:- none}" >> $O
done
