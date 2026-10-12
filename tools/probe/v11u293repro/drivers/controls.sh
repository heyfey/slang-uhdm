#!/bin/bash
# (v11u293) controls.sh <out> <repro dir>... : byte controls. Every case dir (holding dut.sv or dut.v) under the
# given repro dirs, its PATH LIST filtered by $FENCED (word boundary) BEFORE any file is opened, in both views on
# P (pristine) and F (the verified fix); three parallel streams; one line per case-view-binary with rc=.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out.list
for r in "$@"; do find "$REPO/tools/probe/$r" \( -name dut.sv -o -name dut.v \) -printf '%h\n'; done | sort -u | grep -vwE "$FENCE_RE" > $out.list
split -n l/3 $out.list $out.part.
for p in $out.part.*; do
  ( while read -r c; do for el in 0 1; do
      EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /'
      EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /'
    done; done < $p > $p.out ) &
done
wait
cat $out.part.*.out > $out; rm -f $out.part.*
