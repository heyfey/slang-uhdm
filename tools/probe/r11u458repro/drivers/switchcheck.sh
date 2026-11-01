#!/bin/bash
# switchcheck.sh <law-bin> <pristine-bin> <casedir>...: per case, md5 of
# pristine, of the law binary with R11U458_OFF=1 and with each law's switch
# alone; prints OFF=same|DIFF.  Explicit case directories only.
L=$1; P=$2; shift 2
[ -x "$L" ] && [ -x "$P" ] || { echo "no binary"; exit 1; }
W=/tmp/r11u458_sw; mkdir -p $W
for c in "$@"; do
  [ -d "$c" ] || continue
  run(){ rm -f $W/o.uhdm; (cd "$c" && env "$@" dut.sv -o $W/o.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $W/o.uhdm | cut -c1-8)"; }
  p=$(run $P); off=$(run R11U458_OFF=1 $L); a=$(run R11U458_MEMBALIASNAME_OFF=1 $L); b=$(run R11U458_SUBRCOPYNAME_OFF=1 $L); t=$(run R11U458_CLONETWIN_OFF=1 $L); l=$(run $L)
  echo "${c#*/cases/} pris=$p off=$off $([ $p = $off ] && echo OFF=same || echo OFF=DIFF) law=$l membalias_off=$a subrcopy_off=$b clonetwin_off=$t"
done
