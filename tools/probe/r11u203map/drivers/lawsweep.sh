#!/bin/bash
. /tmp/wt_r11u203/tools/probe/r11u203map/drivers/env.sh
DR=/tmp/wt_r11u203/tools/probe/r11u203map/drivers
export SLANG_UHDM=/tmp/r11u203_bin/slang-uhdm.law200
rm -rf /tmp/r11u203_cen; mkdir -p /tmp/r11u203_cen
bash $DR/census.sh /tmp/r11u203_cen/wd /tmp/r11u203_cen/trace /tmp/r11u203_cen/census > /tmp/r11u203_cen/census.log 2>&1
(cd /tmp/wt_r11u203 && python3 $DR/censum.py /tmp/r11u203_cen/trace /tmp/r11u203_cen/wd) > /tmp/r11u203_cen/census_law.txt
chmod 444 /tmp/r11u203_cen/census_law.txt; date -Iseconds > /tmp/r11u203_cen/frozen_at.txt; ls -l --time-style=full-iso /tmp/r11u203_cen/census_law.txt >> /tmp/r11u203_cen/frozen_at.txt
echo CENSUS_FROZEN
cd /tmp/wt_r11u203 && tests/sweep.sh --jobs 3 --workdir /tmp/r11u203_sL > /tmp/r11u203_sL.log 2>&1; echo "sweep rc=$?" >> /tmp/r11u203_sL.log
echo SWEEP_DONE
