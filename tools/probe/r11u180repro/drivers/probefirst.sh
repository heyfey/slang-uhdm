#!/bin/bash
# probefirst.sh <sweep A> <sweep B> <case (probe.csv key)>... : the strict comparator's first records of a probe
# case's database in two sweeps against its cached golden (scripts/check_probe.py's cache key).
set -u; . /tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh || exit 2
A=$1; B=$2; shift 2
for c in "$@"; do
  g=$(cd /tmp/wt_r11u180 && python3 -c "import sys; sys.path.insert(0,'scripts'); import check_probe as cp, verify_golden as vg; h=vg.cache_load(cp.cache_dir('$c')); print(h[1] if h else '')")
  k=$(echo $c | sed 's|/|__|g')
  for W in $A $B; do
    echo "== $c @ $(basename $W)"
    $STRICT_CMP --max ${MAX:-3} $g $W/probe/$k.uhdm | grep -v '^  B' | head -${LINES:-12}
  done
done
