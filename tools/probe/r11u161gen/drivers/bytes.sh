#!/bin/bash
# bytes.sh <binA> <binB> <out.tsv> <root>... : every dut.sv under the roots (sub-dirs included) exported by both
# binaries with check_probe's arguments (--single-unit --nobuiltin), md5 of each database; prints MOVED/SAME/FAIL rows.
# Fail-closed on $FENCED (paths naming a fenced test are refused).
[ -n "$FENCED" ] || { echo "bytes.sh: source drivers/env.sh" >&2; exit 2; }
A=$1; B=$2; out=$3; shift 3
L=$(mktemp /tmp/r11u161_scratch/byteslist.XXXX); find "$@" -name dut.sv | sort | grep -vwE "$(echo $FENCED | tr ' ' '|')" > $L
W=$(mktemp -d /tmp/r11u161_scratch/bytesw.XXXX); : > $out
while read -u 3 f; do
  c=$(dirname $f); rm -f $W/a.uhdm $W/b.uhdm
  (cd $c && timeout 300 $A dut.sv --single-unit --nobuiltin -o $W/a.uhdm > /dev/null 2>&1 </dev/null); ra=$?
  (cd $c && timeout 300 $B dut.sv --single-unit --nobuiltin -o $W/b.uhdm > /dev/null 2>&1 </dev/null); rb=$?
  ma=$(md5sum < $W/a.uhdm 2>/dev/null | cut -c1-12); mb=$(md5sum < $W/b.uhdm 2>/dev/null | cut -c1-12)
  if [ -z "$ma" ] || [ -z "$mb" ]; then v=FAIL; elif [ "$ma" = "$mb" ]; then v=SAME; else v=MOVED; fi
  echo -e "$v\t$c\t$ra\t$rb\t$ma\t$mb" >> $out
done 3< $L
echo "PROCESSED $(wc -l < $out) LISTED $(wc -l < $L) MOVED $(grep -c ^MOVED $out) FAIL $(grep -c ^FAIL $out)"; rm -rf $L $W
