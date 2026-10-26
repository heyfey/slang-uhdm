#!/bin/bash
# epcensus.sh <law binary> <pristine binary> <case dir>...: law against pristine (bytes and exit
# code) per earlier-pass case dir, as run1.sh runs it (TOP / FILES honoured, outputs at one path)
L=$1; P=$2; shift 2
for v in "$L" "$P"; do [ -x "$v" ] || { echo "missing $v"; exit 2; }; done
for c0 in "$@"; do
  c=$(cd /tmp/wt_r11u433/tools/probe/$c0 && pwd); k=$(echo $c0 | sed 's|/|__|g')
  SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
  GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
  o=/tmp/r11u433_scr/ep/$k; rm -rf $o; mkdir -p $o
  (cd $c && timeout 300 $P $SRC $GT --single-unit --nobuiltin -o $o/x.uhdm > /dev/null 2>&1; echo $? > $o/p.rc); mv $o/x.uhdm $o/p.uhdm 2>/dev/null
  (cd $c && timeout 300 $L $SRC $GT --single-unit --nobuiltin -o $o/x.uhdm > /dev/null 2>&1; echo $? > $o/l.rc); mv $o/x.uhdm $o/l.uhdm 2>/dev/null
  if cmp -s $o/p.uhdm $o/l.uhdm && [ "$(cat $o/p.rc)" = "$(cat $o/l.rc)" ]; then echo "SAME $c0 rc=$(cat $o/l.rc)"; rm -f $o/*.uhdm; else echo "MOVED $c0 rc=$(cat $o/p.rc)/$(cat $o/l.rc)"; fi
done
