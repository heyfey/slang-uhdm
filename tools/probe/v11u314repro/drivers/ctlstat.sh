#!/bin/bash
# v11u314 ctlstat.sh <movers> <out>: for each `MOVER <dir under tools/probe> <view>:` line, case.sh on the pristine and
# the law binary (golden built by case.sh on a miss): `<dir> <view> P: <status> | L: <status>`.  Fail-closed on $FENCED.
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2
R=$(cd "$H/../.." && pwd)
grep '^MOVER' "$1" | while read -r _ c v; do v=${v%:}
  for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "$c REFUSED"; continue 2; }; done
  echo "$c $v P: $(bash $H/case.sh $R/$c $P $v) | L: $(bash $H/case.sh $R/$c $L $v)"
done > "$2"
