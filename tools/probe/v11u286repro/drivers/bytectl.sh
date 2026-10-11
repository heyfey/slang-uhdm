#!/bin/bash
# v11u286 bytectl.sh <out> <binA> <binB>: byte controls over every earlier repro case dir under tools/probe (dut.sv),
# both views, the path list built first and filtered by $FENCED (word boundary) before any file is opened.
# One line per case-view: <case> <view> rcA rcB md5A md5B SAME|MOVE.
HERE=$(cd "$(dirname "$0")" && pwd); source "$HERE/env.sh" || exit 3
OUT=$1; A=$2; B=$3; [ -x "$A" ] && [ -x "$B" ] || exit 2
TP=$(cd "$HERE/../.." && pwd); export A B TP
cd $TP && find . -name dut.sv -not -path './v11u286repro/*' -not -path './r11u286repro/*' | grep -vP "$FENCERE" | sort | sed 's#/dut.sv$##' > /tmp/v11u286_s/ctl_list.txt
one() {
  d=$1; for v in d e; do
    ex=""; [ $v = e ] && ex="--elabuhdm"; r=""
    for b in $A $B; do
      o=/tmp/v11u286_s/ctlout/$(echo "$d$v$b$$" | md5sum | cut -c1-16).uhdm; rm -f $o
      (cd $TP/$d && timeout 300 $b dut.sv --single-unit --nobuiltin $ex -o $o >/dev/null 2>&1 </dev/null); rc=$?
      m=nodb; [ -s $o ] && m=$(md5sum < $o | cut -c1-12); rm -f $o; r="$r $rc $m"
    done
    set -- $r; s=SAME; [ "$2" != "$4" ] && s=MOVE; [ "$1" != "$3" ] && s=RCDIFF
    echo "$d $v rc=$1/$3 $2 $4 $s"
  done
}
export -f one; mkdir -p /tmp/v11u286_s/ctlout
xargs -P 3 -I{} bash -c 'one {}' < /tmp/v11u286_s/ctl_list.txt > $OUT
