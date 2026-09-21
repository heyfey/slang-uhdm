#!/usr/bin/env bash
# r11u80 SWITCH LEDGER.  usage: GRID=<dir> sw80.sh <patched-binary> <pristine-binary>
# For every arm and every switch setting, the number of dump lines differing
# from the PRISTINE binary's database (dump-path normalised, header dropped).
# `R11U80_OFF=1` must be 0 on every arm; each single switch must return
# exactly its own arms.
set -u
FIX=${1:?patched binary}; PRIS=${2:?pristine binary}
GRID=${GRID:?set GRID}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
T=${T:-/tmp/r11u80_sw}
mkdir -p $T
ARMS=${ARMS:-$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)}
norm() { sed -e 's#/tmp/[^ ,]*/##g' -e '1d' "$1"; }
printf '%-22s %8s %8s %8s %8s\n' arm ON OFF HOLDER_OFF VARNT_OFF
for a in $ARMS; do
  d=$GRID/$a
  [ -f "$d/dut.sv" ] || continue
  ( cd $d && $PRIS dut.sv --single-unit --nobuiltin -o $T/$a.pris.uhdm >/dev/null 2>&1 )
  $DUMP $T/$a.pris.uhdm > $T/$a.pris.dump 2>&1
  row=""
  for sw in NONE R11U80_OFF R11U80_HOLDER_OFF R11U80_VARNT_OFF; do
    ( cd $d && if [ "$sw" = NONE ]; then $FIX dut.sv --single-unit --nobuiltin -o $T/$a.$sw.uhdm >/dev/null 2>&1;
      else env $sw=1 $FIX dut.sv --single-unit --nobuiltin -o $T/$a.$sw.uhdm >/dev/null 2>&1; fi )
    $DUMP $T/$a.$sw.uhdm > $T/$a.$sw.dump 2>&1
    n=$(diff <(norm $T/$a.pris.dump) <(norm $T/$a.$sw.dump) | grep -c '^[<>]'; true)
    row="$row $n"
  done
  printf '%-22s %8s %8s %8s %8s\n' $a $row
done
