#!/bin/bash
# switches.sh <casedir>...: per-law switch runs on the law binary; prints each switch's md5
cd /tmp/wt_v11u446/tools/probe/v11u446repro
for c in "$@"; do
  for sw in CLSTDTOPHOME AGGCLSMEM ENUMBASEBARE IMPGRPORDER CLSCALLHOME CLONECALLHOME CLSTDQLOCAL; do
    drivers/run1.sh $c /tmp/v11u446_bin/law sw_$sw R11U446_${sw}_OFF=1
  done
done
