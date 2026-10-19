#!/bin/bash
r=$1; SC=/tmp/wt_v11u412/build/uhdm-strictcmp
o=$(timeout 900 $SC /tmp/intr11u410/svtests/work/$r/slang.uhdm /tmp/v11u412_lwd/svtests/work/$r/slang.uhdm 2>&1 | tail -1)
echo "$r | $o"
