#!/bin/bash
# attrib_probe.sh <pristine probe dir> <case key>...: per probe byte mover (key = rel path with
# '/' as '__'), rerun the law binary with R11U160_OFF=1 and with each switch alone; print whether
# OFF gives the pristine bytes and which switches change the law bytes.
P=$1; shift; LAW=${LAW:-/tmp/r11u160_bin/law.bin}; T=${TMPD:-/tmp/r11u160_pattr}; mkdir -p $T
R=$(cd "$(dirname "$0")/../../../.." && pwd)/tests/probe
SW="R11U160_CATCH_OFF R11U160_OBJMACROPAREN_OFF R11U160_TPWHOLELHS_OFF R11U160_TPPACKEDVEC_OFF R11U160_BODYTPDEF_OFF R11U160_TPUSEDEF_OFF R11U160_TPUSEUNIT_OFF R11U160_PPINACTIVE_OFF R11U160_PPARGNL_OFF R11U160_PPBUILTIN_OFF R11U160_PPSTRINGIFY_OFF R11U160_PPPASTE_OFF R11U160_PPNESTCOL_OFF R11U160_PPPUSHLINE_OFF R11U160_IMPLBAREPARAM_OFF"
for k in "$@"; do
  d=$R/$(echo $k | sed 's#__#/#g')
  run() { rm -f $T/o.uhdm; (cd $d && env "$@" $LAW dut.sv --single-unit --nobuiltin -o $T/o.uhdm > /dev/null 2>&1); }
  run; cp $T/o.uhdm $T/law.uhdm
  run R11U160_OFF=1; off=$(cmp -s $T/o.uhdm $P/$k.uhdm && echo pristine || echo DIFF)
  c=""; for s in $SW; do run $s=1; cmp -s $T/o.uhdm $T/law.uhdm || c="$c ${s#R11U160_}"; done
  echo "$k | OFF:$off | contributing:${c:- none}"
done
