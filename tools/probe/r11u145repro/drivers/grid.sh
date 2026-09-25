#!/bin/bash
# grid.sh <bin>... : every case under this directory on each binary: rc, uhdm-cmp lines, strict verdict
# (golden: the pinned Surelog with the probe flags, cached per case dir by /tmp/r11u145_s/rc.sh).
D=$(cd "$(dirname "$0")/.." && pwd)
for c in $(cd $D && find . -name dut.sv | sort | xargs -n1 dirname | sed 's#^\./##'); do
  for b in "$@"; do printf '%-40s ' "$c"; /tmp/r11u145_s/rc.sh $D/$c $b | cut -d' ' -f2-; done
done
