#!/bin/bash
# bytecmp.sh <new_root> <ctl_root>: path-normalized uhdm-dump comparison of every slang.uhdm / probe db under new_root
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "no dump"; exit 1; }
N=$1; C=$2
one() { f=$1; rel=${f#$N/}
  [ -f "$C/$rel" ] || { echo "NOCTL $rel"; return; }
  if cmp -s "$f" "$C/$rel"; then echo "SAMEBYTES $rel"; return; fi
  a=$(timeout 900 $D "$f" 2>/dev/null | sed '1d; s|/tmp/wt_v11u433/|REPO/|g; s|/tmp/[A-Za-z0-9_]*/|ROOT/|g; s|/home/heyfey/git-repos/slang-uhdm/|REPO/|g' | md5sum)
  b=$(timeout 900 $D "$C/$rel" 2>/dev/null | sed '1d; s|/tmp/wt_v11u433/|REPO/|g; s|/tmp/[A-Za-z0-9_]*/|ROOT/|g; s|/home/heyfey/git-repos/slang-uhdm/|REPO/|g' | md5sum)
  [ "$a" = "$b" ] && echo "SAMEDUMP $rel" || echo "MOVER $rel"; }
export -f one; export D N C
find $N -name '*.uhdm' | grep -v -F -f /tmp/v11u433_scr/fenced.txt | grep -v '/slpp_all/' | xargs -P 3 -I{} bash -c 'one {}'
