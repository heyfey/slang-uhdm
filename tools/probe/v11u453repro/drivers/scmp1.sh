#!/bin/bash
C=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
[ -x "$C" ] || exit 2
n=$(timeout 1200 $C /tmp/intr11u450/$1 /tmp/v11u453swp/$1 2>&1 | wc -l); echo "$1 uhdm-cmp-lines=$n rc=${PIPESTATUS[0]}"
