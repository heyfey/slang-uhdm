#!/bin/bash
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; p=$1
a=$($D /tmp/r11u411_w2/svtests/work/$p 2>/dev/null | sed 's#/tmp/r11u411_w2#WD#g; s#/tmp/intr11u412#WD#g' | tail -n +2 | md5sum | cut -c1-10)
b=$($D /tmp/intr11u412/svtests/work/$p 2>/dev/null | sed 's#/tmp/r11u411_w2#WD#g; s#/tmp/intr11u412#WD#g' | tail -n +2 | md5sum | cut -c1-10)
[ "$a" = "$b" ] && echo "SAME $p" || echo "DIFF $p"
