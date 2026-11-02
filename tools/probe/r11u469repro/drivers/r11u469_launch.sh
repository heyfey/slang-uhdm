#!/bin/bash
/tmp/r11u469_wait.sh
source /tmp/r11u469_env.sh
export SLANG_UHDM=/tmp/r11u469_bin/law4 R11U469_TRACE=/tmp/r11u469_swtrace
rm -rf /tmp/r11u469_sw /tmp/r11u469_swtrace; mkdir -p /tmp/r11u469_sw /tmp/r11u469_swtrace
cd /tmp/wt_r11u469 && bash tests/sweep.sh --jobs 3 --workdir /tmp/r11u469_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/r11u469_s4.log 2>&1
echo "rc4=$?" >> /tmp/r11u469_s4.log
cd /home/heyfey/git-repos/slang-uhdm && bash tests/sweep.sh --jobs 3 --workdir /tmp/r11u469_sw --corpus svtests > /tmp/r11u469_ssv.log 2>&1
echo "rcsv=$?" >> /tmp/r11u469_ssv.log
