#!/bin/bash
# probecmp.sh <law binary> <pristine binary> <probe case dir>...: per tests/probe case,
# whether the law binary writes the pristine bytes (exit codes too), with the law trace
L=$1; P=$2; shift 2
for v in "$L" "$P"; do [ -x "$v" ] || { echo "missing $v"; exit 2; }; done
for c in "$@"; do
  k=$(echo $c | sed 's|.*/tests/probe/||; s|/|__|g')
  o=/tmp/r11u433_scr/pc/$k; rm -rf $o; mkdir -p $o/tr
  (cd $c && timeout 300 $P dut.sv --single-unit --nobuiltin -o $o/p.uhdm > /dev/null 2>&1; echo $? > $o/p.rc)
  (cd $c && R11U433_TRACE=$o/tr timeout 300 $L dut.sv --single-unit --nobuiltin -o $o/l.uhdm > /dev/null 2>&1; echo $? > $o/l.rc)
  n=$(cat $o/tr/* 2>/dev/null | grep -v '^OUT' | grep -vc abstain)
  if cmp -s $o/p.uhdm $o/l.uhdm && [ "$(cat $o/p.rc)" = "$(cat $o/l.rc)" ]; then echo "SAME $k fires=$n"; else echo "MOVED $k fires=$n"; fi
done
