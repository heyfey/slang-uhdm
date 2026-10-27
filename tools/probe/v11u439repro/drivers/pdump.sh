#!/bin/bash
DU=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$DU" ] || { echo missing; exit 2; }
f=$1
a=$($DU /tmp/v11u439_VF/probe/$f 2>/dev/null | sed 1d | sed 's#/tmp/v11u439_VF#WD#g; s#/tmp/intr11u437#WD#g; s#/tmp/wt_v11u439/#ROOT/#g; s#/home/heyfey/git-repos/slang-uhdm/#ROOT/#g' | md5sum)
b=$($DU /tmp/intr11u437/probe/$f 2>/dev/null | sed 1d | sed 's#/tmp/v11u439_VF#WD#g; s#/tmp/intr11u437#WD#g; s#/tmp/wt_v11u439/#ROOT/#g; s#/home/heyfey/git-repos/slang-uhdm/#ROOT/#g' | md5sum)
[ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
