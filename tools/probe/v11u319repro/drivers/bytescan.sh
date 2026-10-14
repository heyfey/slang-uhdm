#!/bin/bash
# v11u319 bytescan.sh <outdir> <binA> <binB>: every fence-filtered tools/probe dut.sv of this checkout (the path list
# filtered by $FENCED BEFORE any file is opened) in both views on two binaries; one line per case-view:
# <rcA> <rcB> <view> <dir> same|MOVE.
D=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$D/../../../.." && pwd)
FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bytescan: FENCED not 4 names" >&2; exit 2; }
FR=$(echo $FENCED | tr ' ' '|')
OUT=$1; A=$2; Bb=$3; [ -x "$A" ] && [ -x "$Bb" ] || { echo "bytescan: binaries" >&2; exit 2; }
rm -rf $OUT; mkdir -p $OUT/o
cd $REPO/tools/probe && find . -name dut.sv | grep -vwE "$FR" | sort > $OUT/list.txt
one() { d=$(dirname "$1"); k=$(echo "$d" | tr '/' '_'); for el in 0 1; do ox=""; [ $el = 1 ] && ox=--elabuhdm
  (cd "$d" && timeout 120 $A dut.sv --single-unit --nobuiltin $ox -o $OUT/o/$k.$el.a.uhdm >/dev/null 2>&1); ra=$?
  (cd "$d" && timeout 120 $Bb dut.sv --single-unit --nobuiltin $ox -o $OUT/o/$k.$el.b.uhdm >/dev/null 2>&1); rb=$?
  m=same; cmp -s $OUT/o/$k.$el.a.uhdm $OUT/o/$k.$el.b.uhdm || m=MOVE
  echo "$ra $rb $el $d $m"; rm -f $OUT/o/$k.$el.a.uhdm $OUT/o/$k.$el.b.uhdm; done; }
export -f one; export A Bb OUT
xargs -a $OUT/list.txt -P ${BSJOBS:-4} -I{} bash -c 'one {}' > $OUT/scan.txt
