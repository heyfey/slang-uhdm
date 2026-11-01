#!/bin/bash
# bytecheck: run pristine and law on each case dir (dut.sv or FILES, TOP), compare rc and output md5
P=/tmp/v11u461_bin/pristine; L=/tmp/v11u461_bin/law
for c in "$@"; do
  [ -d "$c" ] || continue
  SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); [ -f $c/$SRC ] || [ -f $c/FILES ] || continue
  GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
  o=/tmp/v11u461_bc/$(echo $c | md5sum | cut -c1-10); rm -rf $o; mkdir -p $o
  (cd $c && timeout 300 $P $SRC $GT --single-unit --nobuiltin -o $o/p.uhdm >/dev/null 2>&1; echo $? > $o/prc)
  (cd $c && timeout 300 $L $SRC $GT --single-unit --nobuiltin -o $o/l.uhdm >/dev/null 2>&1; echo $? > $o/lrc)
  a=$(md5sum < $o/p.uhdm 2>/dev/null | cut -c1-8); b=$(md5sum < $o/l.uhdm 2>/dev/null | cut -c1-8)
  s=same; [ "$a" = "$b" ] && [ "$(cat $o/prc)" = "$(cat $o/lrc)" ] || s=MOVED
  echo "$c prc=$(cat $o/prc) lrc=$(cat $o/lrc) $s"
done
