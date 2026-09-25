#!/bin/bash
# sweep.sh <tag: ON|OF|X0|X4> [corpora]  -- one full sweep of the frozen base binary under a switch set
# ON = laws on (on.bin), OF = R11U140_OFF+R11U144_OFF (off.sh), X0 = R11U140_OFF (off140.sh), X4 = R11U144_OFF (off144.sh)
source /tmp/wt_r11u149/tools/probe/r11u149verify/drivers/env.sh
case $1 in ON) b=on.bin;; FX) b=fix.bin;; OF) b=off.sh;; X0) b=off140.sh;; X4) b=off144.sh;; esac
export SLANG_UHDM=/tmp/r11u149_bin/$b
W=/tmp/r11u149_w$1; mkdir -p $W
cd /tmp/wt_r11u149 && tests/sweep.sh --jobs 3 --workdir $W --corpus "${2:-probe surelog uhdm2rtlil downstream}" > $W.log 2>&1
echo "SWEEP_RC=$?" >> $W.log
