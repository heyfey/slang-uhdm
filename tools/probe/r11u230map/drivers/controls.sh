#!/bin/bash
# r11u230map: the positive controls on the HEAD sweep's databases ($H, read-only): three CMP_EQUAL rows read
# STRICT_EQUAL with identical record dumps and uhdm-cmp at 0 lines; stamped_gen_param stays stage-1 NOT_EQUAL.
# usage: controls.sh <out dir>
. "$(dirname "$0")/env.sh"
for v in STRICT_CMP UHDM_CMP; do [ -x "${!v}" ] || { echo "controls.sh: $v not executable" >&2; exit 2; }; done
[ -x "$B/strictcmp_x" ] || { echo "controls.sh: strictcmp_x not executable" >&2; exit 2; }
O=${1:?out dir}; mkdir -p $O
for x in "surelog default 1364_2005" "surelog default HierPathInterfBlock" "uhdm2rtlil default 1DUnpackedArray" \
         "uhdm2rtlil default stamped_gen_param" "uhdm2rtlil testflags stamped_gen_param"; do
  set -- $x; c=$1; m=$2; t=$3
  echo "$t" | grep -Pq "$FENCERE" && { echo "FENCED refused"; continue; }
  d=$(ls -d $H/$c/$m/$t-* | head -1); g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
  st=$(grep "^$t,$m," $H/$c.csv | cut -d, -f3)
  "$B/strictcmp_x" --max 50 --dump-a $O/${t}_$m.a --dump-b $O/${t}_$m.b $g $d/slang.uhdm > $O/${t}_$m.out 2>&1; rc=$?
  v=$(grep -o '^STRICT_[A-Z_]*.*' $O/${t}_$m.out | head -1)
  if [ -s $O/${t}_$m.a ]; then n=$(grep -c . $O/${t}_$m.a); dl=$(diff <(cut -f1-14 $O/${t}_$m.a) <(cut -f1-14 $O/${t}_$m.b) | grep -c '^[<>]')
  else n='-'; dl='- (stage 1: no record walk)'; v="stage 1: $(tail -2 $O/${t}_$m.out | head -1)"; fi
  cm=$("$UHDM_CMP" $g $d/slang.uhdm > $O/${t}_$m.cmp 2>&1; echo $?); cl=$(grep -c . $O/${t}_$m.cmp)
  echo "$c/$m/$t csv=$st strictcmp_x rc=$rc [$v] records=$n dump-lines-differing=$dl uhdm-cmp rc=$cm lines=$cl"
  rm -f $O/${t}_$m.a $O/${t}_$m.b
done
