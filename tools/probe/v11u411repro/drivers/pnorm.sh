#!/bin/bash
# pnorm.sh <file>: compare path-normalized dumps of law-sweep probe db vs control
f=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
a=$($D /tmp/v11u411_wL/probe/$f 2>/dev/null | sed -e 's#/tmp/wt_v11u411#ROOT#g; s#/home/heyfey/git-repos/slang-uhdm#ROOT#g; s#/tmp/v11u411_wL#WD#g; s#/tmp/intr11u412#WD#g' | md5sum)
b=$($D /tmp/intr11u412/probe/$f 2>/dev/null | sed -e 's#/tmp/wt_v11u411#ROOT#g; s#/home/heyfey/git-repos/slang-uhdm#ROOT#g; s#/tmp/v11u411_wL#WD#g; s#/tmp/intr11u412#WD#g' | md5sum)
[ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
