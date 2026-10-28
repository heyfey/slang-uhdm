#!/bin/bash
# probedump.sh <file.uhdm basename>: path-normalized dump compare law vs control
f=$1; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || exit 2
norm(){ $D $1 2>/dev/null | tail -n +2 | sed -e 's|/tmp/wt_v11u450|ROOT|g' -e 's|/home/heyfey/git-repos/slang-uhdm|ROOT|g' -e 's|/tmp/v11u450swl|WD|g' -e 's|/tmp/intr11u449|WD|g' | md5sum | cut -c1-16; }
a=$(norm /tmp/v11u450swl/probe/$f); b=$(norm /tmp/intr11u449/probe/$f)
[ "$a" = "$b" ] && echo "SAME $f" || echo "MOVED $f"
