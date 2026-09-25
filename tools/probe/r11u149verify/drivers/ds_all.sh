#!/bin/bash
# ds_all.sh: every case of this directory through ds.py under ON (both landings on), OF (both off) and FX (the fix binary)
source /tmp/wt_r11u149/tools/probe/r11u149verify/drivers/env.sh
export GOLDEN_CACHE=/tmp/r11u149_gc_ds
L=$(ls -d /tmp/wt_r11u149/tools/probe/r11u149verify/cases/*/*/ | sed 's#/$##')
for t in ON:on.bin OF:off.sh FX:fix.bin; do
  SLANG_UHDM=/tmp/r11u149_bin/${t#*:} python3 /tmp/wt_r11u149/tools/probe/r11u149verify/drivers/ds.py ${t%%:*} $L > /tmp/r11u149_ds_${t%%:*}.txt 2>&1 &
done
wait
