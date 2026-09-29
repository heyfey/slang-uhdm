#!/bin/bash
# r11u223: the per-law switch table. For every case-view of cases/<fam>, the law binary under each law switch; prints
# <case-view> <switch>=pristine|law|other (pristine: the bytes of $B/pristine; law: the bytes of $B/${LAWBIN:-law} with no switch).
# Fail-closed on $FENCED (case.sh). usage: switches.sh <cases dir> <switch>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3; export S=${S:-/tmp/r11u223_s}
D=$1; shift
for c in $(find "$(realpath $D)" -name dut.sv -printf '%h\n' | sort); do for el in 0 1; do
  p=$(EL=$el bash $HERE/case.sh $c SWP $B/pristine 2>/dev/null | grep -o 'md5=[0-9a-f]*\|rc=[0-9]*' | tr '\n' ' ')
  l=$(EL=$el bash $HERE/case.sh $c SWL $B/${LAWBIN:-law} 2>/dev/null | grep -o 'md5=[0-9a-f]*\|rc=[0-9]*' | tr '\n' ' ')
  line="$(basename $(dirname $c))/$(basename $c)$([ $el = 1 ] && echo _el)"
  for sw in "$@"; do
    x=$(EL=$el bash $HERE/case.sh $c SWX $B/${LAWBIN:-law} $sw=1 2>/dev/null | grep -o 'md5=[0-9a-f]*\|rc=[0-9]*' | tr '\n' ' ')
    if [ "$x" = "$p" ]; then r=pristine; elif [ "$x" = "$l" ]; then r=law; else r=other; fi
    line="$line $sw=$r"
  done
  echo "$line $([ "$p" = "$l" ] && echo bytes=same || echo bytes=moved)"
done; done
