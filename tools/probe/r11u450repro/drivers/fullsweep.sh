#!/bin/bash
/tmp/wt_r11u450/tools/probe/r11u450repro/drivers/quiet.sh
cd /tmp/wt_r11u450 && source /tmp/r11u450_env.sh && export SLANG_UHDM=/tmp/r11u450_bin/law12
rm -rf /tmp/r11u450swp /tmp/r11u450_swtr; mkdir -p /tmp/r11u450_swtr
date > /tmp/r11u450_sweep.start
R11U450_TRACE=/tmp/r11u450_swtr bash tests/sweep.sh --jobs 3 --workdir /tmp/r11u450swp > /tmp/r11u450_sweep.log 2>&1
echo rc=$? >> /tmp/r11u450_sweep.log
date > /tmp/r11u450_sweep.done
