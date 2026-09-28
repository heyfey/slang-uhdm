#!/bin/bash
# r11u195: each law's own switch, alone, on its own grid: the law binary with R11U<pass>_<LAW>_OFF=1 must write the
# pristine bytes on every case of the law's grid (no other law fires there, or the case is listed as mixed).
# usage: switchcheck.sh   (reads cases/ next to this script; binaries $B/pris.bin $B/lawG.bin; uses case.sh)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
C=$HERE/../cases
for pair in A:R11U191_HPENDCOL_OFF B:R11U191_EARLCOL_OFF C:R11U191_EVALTS_OFF G:R11U195_EVALOP_OFF S:R11U195_FUNCCFGPAT_OFF \
            K:R11U195_PROCNETSEL_OFF P:R11U195_PATMEMLOC_OFF T:R11U195_TPPAREN_OFF; do
  g=${pair%%:*}; sw=${pair#*:}; same=0; diffl=""; n=0
  for d in $(find $C/$g -name dut.sv -printf '%h\n' | sort); do
    r=${d#$C/}; n=$((n+1))
    P=/tmp/r11u195_sw/pris/$r; L=/tmp/r11u195_sw/$sw/$r; LF=/tmp/r11u195_sw/lawG/$r
    [ -s $P/ours.uhdm ] || SLANG_UHDM=$B/pris.bin bash $HERE/case.sh $d $P > /dev/null 2>&1
    env $sw=1 SLANG_UHDM=$B/lawG.bin bash $HERE/case.sh $d $L > /dev/null 2>&1
    if [ "$g" = G ]; then
      # the refinement's switch restores the r11u191 law's bytes, not pristine
      SLANG_UHDM=$B/law191.bin bash $HERE/case.sh $d $LF > /dev/null 2>&1; ref=$LF/ours.uhdm
    else ref=$P/ours.uhdm; fi
    if cmp -s $L/ours.uhdm $ref; then same=$((same+1)); else diffl="$diffl $r"; fi
  done
  echo "$sw grid=$g cases=$n restored=$same others:$diffl"
done
