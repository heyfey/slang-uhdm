#!/bin/bash
# bytecensus.sh <list of case dirs> <binA> <binB> <out.tsv>: runs both binaries on every
# listed case dir (dut.sv, or FILES; TOP gives --top) and prints dir, rc and md5 per binary.
# Output under /tmp/r11u444_scr/census/<key>/{a,b}.uhdm; keys are the full path after tools/ or tests/.
L=$1; A=$2; B=$3; O=$4
[ -x "$A" ] && [ -x "$B" ] || { echo "no binary"; exit 2; }
one() {
  c=$1; A=$2; B=$3
  key=$(echo $c | sed 's|^.*/\(tools\|tests\)/|\1_|; s|/|_|g')
  o=/tmp/r11u444_scr/census/$key; rm -rf $o; mkdir -p $o
  SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
  (cd $c && timeout 300 $A $SRC $GT --single-unit --nobuiltin -o $o/a.uhdm > $o/a.log 2>&1 < /dev/null; echo $? > $o/a.rc)
  (cd $c && timeout 300 $B $SRC $GT --single-unit --nobuiltin -o $o/b.uhdm > $o/b.log 2>&1 < /dev/null; echo $? > $o/b.rc)
  ma=$(md5sum < $o/a.uhdm 2>/dev/null | cut -c1-8); mb=$(md5sum < $o/b.uhdm 2>/dev/null | cut -c1-8)
  printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$c" "$(cat $o/a.rc)" "$ma" "$(cat $o/b.rc)" "$mb" "$([ "$ma" = "$mb" ] && [ "$(cat $o/a.rc)" = "$(cat $o/b.rc)" ] && echo same || echo MOVED)"
}
export -f one
xargs -a $L -P 3 -I{} bash -c 'one "$@"' _ {} $A $B > $O
echo "listed $(wc -l < $L) processed $(wc -l < $O) moved $(grep -c MOVED $O)"
