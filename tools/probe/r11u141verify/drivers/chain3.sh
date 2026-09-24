#!/bin/bash
while kill -0 2754983 2>/dev/null; do sleep 20; done
source /tmp/r11u141_drv/env.sh
export SLANG_UHDM=/tmp/r11u141_bin/fix
cd /tmp/wt_r11u141fix
wd=/tmp/r11u141_wdFX; rm -rf $wd; mkdir -p $wd
echo "tag=FX bin=$SLANG_UHDM start=$(date -Is)" > $wd/CONFIG
tests/sweep.sh --jobs 3 --workdir $wd > $wd/sweep.log 2>&1; echo "rc=$?" >> $wd/CONFIG; echo "end=$(date -Is)" >> $wd/CONFIG
