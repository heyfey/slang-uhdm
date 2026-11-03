#!/bin/bash
# pdump.sh <file>: normalised uhdm-dump md5 of the law and control probe database
f=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; [ -x "$D" ] || exit 1
a=$($D /tmp/r11u474_sw/probe/$f 2>/dev/null | tail -n +2 | sed 's#/tmp/wt_r11u474/#R/#g; s#/home/heyfey/git-repos/slang-uhdm/#R/#g; s#/tmp/r11u474_sw/#W/#g; s#/tmp/intr11u472/#W/#g' | md5sum | cut -c1-12)
b=$($D /tmp/intr11u472/probe/$f 2>/dev/null | tail -n +2 | sed 's#/tmp/wt_r11u474/#R/#g; s#/home/heyfey/git-repos/slang-uhdm/#R/#g; s#/tmp/r11u474_sw/#W/#g; s#/tmp/intr11u472/#W/#g' | md5sum | cut -c1-12)
echo "$f $a $b"
