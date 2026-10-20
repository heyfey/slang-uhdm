#!/bin/bash
# v11u419 probecmp.sh (from r11u419) <law probe dir> <control probe dir>: path-normalized uhdm-dump comparison of
# every probe database (the probe databases embed the checkout path, so bytes differ by tree)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; [ -x $D ] || exit 1
one() { a=$1/$3; b=$2/$3
  x=$($D $a 2>/dev/null | sed 's|/tmp/wt_v11u419|ROOT|g; s|/home/heyfey/git-repos/slang-uhdm|ROOT|g; 1d' | md5sum)
  y=$($D $b 2>/dev/null | sed 's|/tmp/wt_v11u419|ROOT|g; s|/home/heyfey/git-repos/slang-uhdm|ROOT|g; 1d' | md5sum)
  [ "$x" = "$y" ] || echo "MOVER $3"; }
export -f one; export D
ls $1 | grep '\.uhdm$' | xargs -P 3 -I{} bash -c "one $1 $2 {}"
