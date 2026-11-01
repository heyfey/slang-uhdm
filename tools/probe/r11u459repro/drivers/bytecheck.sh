#!/bin/bash
# bytecheck.sh <binA> <binB> <out> <repro dir>...: every case dir (a dir holding dut.sv)
# under the given repro dirs run on both binaries (ours only, no golden), one line per
# case: key rcA rcB same|MOVED.  Paths are fence-filtered before any file is opened.
A=$1; B=$2; O=$3; shift 3
[ -x "$A" ] && [ -x "$B" ] || { echo "no binary"; exit 2; }
FENCE=/tmp/r11u459_s/fence.txt
: > $O
for r in "$@"; do
  find $r -name dut.sv | sort | grep -v -F -f $FENCE | while read f; do
    c=$(dirname $f); SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
    TOP=; [ -f $c/TOP ] && TOP="--top $(cat $c/TOP)"
    for t in a b; do B9=$A; [ $t = b ] && B9=$B
      rm -f /tmp/r11u459_scr/bc_$t.uhdm
      (cd $c && timeout 300 nice -n 19 $B9 $SRC $TOP --single-unit --nobuiltin -o /tmp/r11u459_scr/bc_$t.uhdm > /dev/null 2>&1; echo $? > /tmp/r11u459_scr/bc_$t.rc) < /dev/null
    done
    ma=$(md5sum < /tmp/r11u459_scr/bc_a.uhdm 2>/dev/null | cut -c1-8); mb=$(md5sum < /tmp/r11u459_scr/bc_b.uhdm 2>/dev/null | cut -c1-8)
    echo "${c#/home/heyfey/git-repos/slang-uhdm/tools/probe/} $(cat /tmp/r11u459_scr/bc_a.rc) $(cat /tmp/r11u459_scr/bc_b.rc) $([ "$ma" = "$mb" ] && echo same || echo MOVED)" >> $O
  done
done
