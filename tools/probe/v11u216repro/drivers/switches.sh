#!/bin/bash
# v11u216: each verifier switch alone.  For every case-view of cases/<sub> (both views), fix2 under <SWITCH>=1 is compared
# byte for byte with law.bin (the r11u216 bytes) and with fix2 itself; prints <case-view> <switch> =law|=fix|OTHER.
# usage: switches.sh <sub> <SWITCH>   (uses case.sh: fence fail-closed; law.bin/fix2.bin outputs must exist in $GW)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
sub=$1; sw=$2
for c in $(find $HERE/../cases/$sub -name dut.sv -printf '%h\n' | sort); do for el in 0 1; do
  r=$(EL=$el bash $HERE/case.sh $c sw_$sw $B/fix2.bin $sw=1 2>/dev/null); md=$(echo "$r" | grep -o 'md5=[0-9a-f]*'); cv=$(echo "$r" | awk '{print $1}')
  l=$(EL=$el bash $HERE/case.sh $c law.bin $B/law.bin 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  f=$(EL=$el bash $HERE/case.sh $c fix2.bin $B/fix2.bin 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  v=OTHER; [ "$md" = "$f" ] && v="=fix"; [ "$md" = "$l" ] && v="=law"; [ "$l" = "$f" ] && v="$v(law=fix)"
  echo "$cv $sw $v"; done; done
