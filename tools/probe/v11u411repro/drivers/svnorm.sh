#!/bin/bash
# svnorm.sh <rel path>: path-normalized dump compare, law sweep vs control
f=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; A=${A:-/tmp/v11u411_wL}
case $f in *tnoc*) echo "SKIP $f"; exit;; esac
n(){ timeout 600 $D $1 2>/dev/null | sed -e "s#$A#WD#g; s#/tmp/intr11u412#WD#g; s#/tmp/wt_v11u411#ROOT#g; s#/home/heyfey/git-repos/slang-uhdm#ROOT#g" | md5sum; }
[ "$(n $A/svtests/$f)" = "$(n /tmp/intr11u412/svtests/$f)" ] && echo "SAME $f" || echo "DIFF $f"
