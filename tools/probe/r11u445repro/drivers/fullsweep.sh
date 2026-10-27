#!/bin/bash
source /tmp/wt_r11u445/tools/probe/r11u445repro/drivers/env.sh
export SLANG_UHDM=/tmp/r11u445_bin/law5 R11U445_TRACE=/tmp/r11u445_swtr
[ -x "$SLANG_UHDM" ] || exit 2
q=0
while [ $q -lt 3 ]; do
  if ps -eo pid=,args= | grep -E 'sweep\.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests' | grep -v -e grep -e r11u445 >/dev/null; then q=0; else q=$((q+1)); fi
  sleep 20
done
echo "QUIET $(date)"
cd /tmp/wt_r11u445 && tests/sweep.sh --jobs 3 --workdir /tmp/r11u445_sw
echo "SWEEP_DONE rc=$? $(date)"
