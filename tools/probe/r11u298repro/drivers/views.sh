#!/bin/bash
# r11u298 (copied from r11u294repro) views.sh <binary> <case dir>...: both views of each case dir through case.sh (golden cache $R298_GOLD,
# outputs $R298_OUT), one `== <case> <view> rc=.. cmp=.. <strict verdict> md5=..` line each; V=1 adds the first
# strict records (MAX of them, default 3).  Fail-closed on $FENCED (env.sh, case.sh).
H=$(cd "$(dirname "$0")" && pwd)
source "$H/env.sh" || exit 2
b=$1; shift
for d in "$@"; do for v in d e; do
  r=$(SHOW=1 bash "$H/case.sh" "$d" "$b" $v ${MAX:-3})
  echo "== $(basename $d) $v $(echo "$r" | head -1)"
  [ -n "$V" ] && echo "$r" | sed -n '2,12p' | grep -v '^objects\|^STRICT'
done; done
