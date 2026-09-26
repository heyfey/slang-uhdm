#!/bin/bash
# judge.sh <boundary result.txt> <out.txt> : every MOVER of drivers/boundary.sh judged against its pinned-Surelog golden
# with both binaries (drivers/case.sh), plus the order-blind uhdm-dump distance (ours-not-golden + golden-not-ours).
set -u; . /tmp/wt_r11u176/tools/probe/r11u176repro/drivers/env.sh
grep '^MOVER' $1 | awk '{print $2}' > /tmp/r11u176_scratch/judge.list
one() { d=$1; out=""
  for b in pris final4; do
    l=$(OUT=/tmp/r11u176_scratch/judge TAG=$b /tmp/wt_r11u176/tools/probe/r11u176repro/drivers/case.sh $d /tmp/r11u176_bin/$b.bin 2>&1 | tail -1)
    v=$(echo "$l" | awk '{print $6, $4}')
    k=$(echo $d | sed 's|.*/cases/||; s|/|__|g'); o=/tmp/r11u176_scratch/judge/$k.$b
    ob=NA; if [ -s $o/golden.uhdm ] && [ -s $o/ours.uhdm ]; then g=$($UHDM_DUMP $o/golden.uhdm 2>/dev/null | sed 's|/[^ ,]*/||g' | grep -v 'Restored design' | sort); u=$($UHDM_DUMP $o/ours.uhdm 2>/dev/null | sed 's|/[^ ,]*/||g' | grep -v 'Restored design' | sort); ob=$(( $(comm -13 <(echo "$g") <(echo "$u") | wc -l) + $(comm -23 <(echo "$g") <(echo "$u") | wc -l) )); fi
    out="$out $b:[$v ob=$ob]"; done
  echo "${d#/tmp/wt_r11u176/tools/probe/}$out"; }
export -f one
xargs -a /tmp/r11u176_scratch/judge.list -P 4 -I{} bash -c 'one {}' | sort > $2
