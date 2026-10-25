#!/bin/bash
# probecmp.sh: path-normalized uhdm-dump comparison of the law sweep's probe databases against the control's
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "no uhdm-dump"; exit 1; }
one() { f=$1
  a=$($D /tmp/r11u429sw1/probe/$f 2>/dev/null | sed '1d; s|/tmp/wt_r11u429/|ROOT/|g' | md5sum)
  b=$($D /tmp/intr11u427/probe/$f 2>/dev/null | sed '1d; s|/home/heyfey/git-repos/slang-uhdm/|ROOT/|g' | md5sum)
  [ "$a" = "$b" ] && echo SAME || echo "MOVER $f"; }
export -f one; export D
cd /tmp/r11u429sw1/probe && ls *.uhdm | xargs -P 3 -I{} bash -c 'one {}' | sort | uniq -c | sort -rn | head
