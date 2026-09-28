#!/bin/bash
# gridcmp.sh <tagA> <binA> <tagB> <binB> [casedir-root...]: every case under the roots, both views (VIEWS="" / "1"
# overrides), judged with MAX=100000; one line per case-mode: verdict A -> verdict B, record movement (recmv.py),
# the laws that fired under B, order-blind dump distance (obdist.py) and whether the dump bytes moved.
D=$(cd "$(dirname "$0")" && pwd)
ta=$1; ba=$2; tb=$3; bb=$4; shift 4
roots=("$@"); [ ${#roots[@]} -eq 0 ] && roots=("$D/../cases")
export MAX=100000
for root in "${roots[@]}"; do
  for c in $(find $root -name dut.sv -printf '%h\n' | sort); do
    for e in ${VIEWS-0 1}; do
      [ "$e" = 0 ] && e=""
      a=$(ELAB=$e $D/grid.sh $c $ba $ta); b=$(ELAB=$e $D/grid.sh $c $bb $tb)
      rel=$(echo "$a" | awk '{print $1}')
      w=/tmp/r11u192_g/$rel
      if [ -s $w/$ta.strict ] && [ -s $w/$tb.strict ]; then mv=$(python3 $D/recmv.py $w/$ta.strict $w/$tb.strict 2>/dev/null | head -1); else mv="-"; fi
      ob=$( [ -s $w/$ta.dump ] && [ -s $w/$tb.dump ] && python3 $D/obdist.py $w/gold.dump $w/$ta.dump $w/$tb.dump)
      echo "$rel | $(echo "$a" | grep -oE '(strict=[^ ]*|SLANG_FAIL|SURELOG_FAIL)') cmp=$(echo "$a" | grep -o 'cmplines=[0-9]*' | cut -d= -f2) -> $(echo "$b" | grep -oE '(strict=[^ ]*|SLANG_FAIL|SURELOG_FAIL)') cmp=$(echo "$b" | grep -o 'cmplines=[0-9]*' | cut -d= -f2) | $mv | ob $ob | $(echo "$b" | grep -o 'fires=.*') | $( [ "$(echo "$a" | grep -o 'md5=[0-9a-f]*')" = "$(echo "$b" | grep -o 'md5=[0-9a-f]*')" ] && echo bytes-same || echo bytes-moved)"
    done
  done
done
