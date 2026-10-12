#!/bin/bash
# v11u290 bytectl.sh <out> <repro dir>...: every case dir (holding dut.sv, dut.v or args) under the listed
# tools/probe repro dirs, both views, with $B/pristine, $B/law and $B/fix; one line per case-view with each
# binary's exit code and md5. No golden is built (byte controls). Fail-closed on $FENCED: a case path naming a
# fenced test is skipped before any file is opened.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] && [ -n "$B" ] || { echo "bytectl.sh: source drivers/env.sh" >&2; exit 2; }
for t in pristine law fix; do [ -x "$B/$t" ] || { echo "bytectl.sh: $B/$t not executable" >&2; exit 2; }; done
out=$1; shift; : > $out; W=$(mktemp -d /tmp/v11u290_bc.XXXX)
FR="$(echo $FENCED | tr ' ' '|')"
for r in "$@"; do
  find $r \( -name dut.sv -o -name dut.v -o -name args \) | grep -vwE "$FR" | xargs -r -n1 dirname | sort -u
done | while read -r c; do
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
  for v in d e; do ox=; [ $v = e ] && ox=--elabuhdm; line="$c $v"
    for t in pristine law fix; do rm -f $W/$t.uhdm
      (cd $c && timeout 300 $B/$t $SRC --single-unit --nobuiltin $ox -o $W/$t.uhdm > /dev/null 2>&1); rc=$?
      line="$line $t:rc=$rc:$( [ -s $W/$t.uhdm ] && md5sum < $W/$t.uhdm | cut -c1-8 || echo none)"; done
    echo "$line" >> $out; done
done
rm -rf $W
