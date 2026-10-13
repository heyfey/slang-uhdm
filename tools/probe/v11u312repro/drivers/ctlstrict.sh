#!/bin/bash
# v11u312 ctlstrict.sh <bytescan out> <out>: for every MOVE line outside r11u312repro and v11u312repro, the strict
# verdict of both binaries (case.sh; goldens built into the cache on demand): `<dir> <view> P: <...> L: <...>`.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "ctlstrict: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); R=$(cd "$H/../../../.." && pwd)
grep 'MOVE$' $1 | grep -vE 'r11u312repro|v11u312repro' | while read -r d v _; do
  for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo fenced >&2; exit 2; }; done
  echo "$d $v P: $(bash $H/case.sh $R/$d $VB/pristine-slang-uhdm $v 5) L: $(bash $H/case.sh $R/$d $VB/law-slang-uhdm $v 5)"
done > $2
wc -l < $2
