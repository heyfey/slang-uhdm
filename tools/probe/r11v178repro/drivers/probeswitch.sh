#!/bin/bash
# probeswitch.sh <binary> <workroot> SW...: the probe gate stage once per switch (SW=1), compared with the baseline
B=$1; W=$2; shift 2; SWS=("$@")
source /tmp/v11u178_env.sh; export SLANG_UHDM=$B; cd /tmp/wt_v11u178
for sw in "${SWS[@]}"; do
  env $sw=1 python3 scripts/check_probe.py --jobs 3 --workdir $W/$sw --out $W/$sw.csv > $W/$sw.log 2>&1
  echo "$sw $(python3 scripts/compare_results.py $W/$sw.csv results/golden_probe.csv 2>&1 | grep -E 'regressions=')"
done
