#!/bin/bash
# r11u211: the firing census of the law205 binary (the mover PREDICTION, frozen chmod 444), then its full gate sweep
. /tmp/wt_r11u211/tools/probe/r11u211map/drivers/env.sh
DR=/tmp/wt_r11u211/tools/probe/r11u211map/drivers
export SLANG_UHDM=/tmp/r11u211_bin/slang-uhdm.law205
rm -rf /tmp/r11u211_cen; mkdir -p /tmp/r11u211_cen
bash $DR/census.sh /tmp/r11u211_cen/wd /tmp/r11u211_cen/trace /tmp/r11u211_cen/census > /tmp/r11u211_cen/census.log 2>&1
(cd /tmp/wt_r11u211 && python3 $DR/censum.py /tmp/r11u211_cen/trace /tmp/r11u211_cen/wd) > /tmp/r11u211_cen/census_law.txt
chmod 444 /tmp/r11u211_cen/census_law.txt; date -Iseconds > /tmp/r11u211_cen/frozen_at.txt; ls -l --time-style=full-iso /tmp/r11u211_cen/census_law.txt >> /tmp/r11u211_cen/frozen_at.txt
echo CENSUS_FROZEN
cd /tmp/wt_r11u211 && tests/sweep.sh --jobs 3 --workdir /tmp/r11u211_sL > /tmp/r11u211_sL.log 2>&1; echo "sweep rc=$?" >> /tmp/r11u211_sL.log
echo SWEEP_DONE
