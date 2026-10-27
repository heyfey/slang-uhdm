#!/bin/bash
# usage: probedump.sh <db name>  (compares the path-normalized dumps of the law and control probe databases)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "MISSING_DUMP"; exit 2; }
f=$1
a=$($D /tmp/r11u441_LW/probe/$f 2>/dev/null | sed 1d | sed 's#/tmp/r11u441_LW#W#g; s#/tmp/intr11u439#W#g; s#/tmp/wt_r11u441/#R/#g; s#/home/heyfey/git-repos/slang-uhdm/#R/#g' | md5sum)
b=$($D /tmp/intr11u439/probe/$f 2>/dev/null | sed 1d | sed 's#/tmp/r11u441_LW#W#g; s#/tmp/intr11u439#W#g; s#/tmp/wt_r11u441/#R/#g; s#/home/heyfey/git-repos/slang-uhdm/#R/#g' | md5sum)
[ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
