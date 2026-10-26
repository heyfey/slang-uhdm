#!/bin/bash
f=$1; d=$(dirname /home/heyfey/git-repos/slang-uhdm/$f); k=$(echo $f | tr / _)
[ -x /tmp/r11u438_bin/law5 ] || exit 2
(cd $d && R11U438_TRACE=/tmp/r11u438_s/ptr timeout 120 /tmp/r11u438_bin/law5 dut.sv --single-unit --nobuiltin -o /tmp/r11u438_s/pout/$k.uhdm >/dev/null 2>&1 </dev/null); rm -f /tmp/r11u438_s/pout/$k.uhdm
