#!/bin/bash
# usage: probedump.sh <workdir> <db name>  (path-normalized dump of <workdir>/probe/<db> vs the control's)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "MISSING_DUMP"; exit 2; }
W=$1; f=$2
n(){ sed 1d | sed "s#$W#W#g; s#/tmp/intr11u439#W#g; s#/tmp/wt_v11u441/#R/#g; s#/home/heyfey/git-repos/slang-uhdm/#R/#g" | md5sum; }
a=$($D $W/probe/$f 2>/dev/null | n); b=$($D /tmp/intr11u439/probe/$f 2>/dev/null | n)
[ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
