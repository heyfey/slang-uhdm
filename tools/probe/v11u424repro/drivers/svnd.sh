#!/bin/bash
# svnd.sh <rel path>: path-normalized dump compare law sweep vs control
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; [ -x $D ] || exit 1
f=$1; k=$(echo $f | sed 's|^\./||; s|/slang.uhdm||; s|/|_|g'); W=/tmp/v11u424_scr/svnd; mkdir -p $W
timeout 900 $D /tmp/v11u424wd/svtests/work/$f 2>/dev/null | sed 's|/tmp/v11u424wd|WD|g; s/id:[0-9]*//g' | md5sum | cut -c1-10 > $W/$k.l; rl=${PIPESTATUS[0]}
timeout 900 $D /tmp/intr11u422/svtests/work/$f 2>/dev/null | sed 's|/tmp/intr11u422|WD|g; s/id:[0-9]*//g' | md5sum | cut -c1-10 > $W/$k.c
echo "$f $(cat $W/$k.l) $(cat $W/$k.c) $([ "$(cat $W/$k.l)" = "$(cat $W/$k.c)" ] && echo SAME || echo MOVED)"
