#!/bin/bash
# predsv.sh: traced runner on the sv-tests candidate rows (plus the 48 non-equal rows) on the law binary
export R11U431_TRACE=/tmp/r11u431_predsv/trace
mkdir -p $R11U431_TRACE
cat /tmp/r11u431_scan/sv_any.lst /tmp/r11u431_scr/ne48.lst | grep . | sort -u > /tmp/r11u431_predsv/rows.lst
/tmp/r11u431_scr/runrows.sh /tmp/r11u431_law9/slang-uhdm /tmp/r11u431_predsv/rows.lst /tmp/r11u431_predsv/sv.csv /tmp/r11u431_predsv/work
echo PREDSVDONE
