#!/bin/bash
f=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
a=$($D /tmp/v11u448_sw/probe/$f 2>&1 | sed 's#/tmp/wt_v11u448/##g; s#/home/heyfey/git-repos/slang-uhdm/##g; s#/tmp/v11u448_sw#WD#g; s#, id:[0-9]*##g' | sed 1d | md5sum)
b=$($D /tmp/intr11u446/probe/$f 2>&1 | sed 's#/tmp/wt_v11u448/##g; s#/home/heyfey/git-repos/slang-uhdm/##g; s#/tmp/intr11u446#WD#g; s#, id:[0-9]*##g' | sed 1d | md5sum)
[ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
