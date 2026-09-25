#!/bin/bash
# gridrun.sh <pristine bin> <law bin> : every case under ../cases judged against its pinned-Surelog golden
# (drivers/case.sh: probe arguments, own content-keyed golden cache /tmp/r11u172_gold) with both binaries.
D=$(cd "$(dirname "$0")" && pwd); C=$(cd $D/../cases && pwd)
: "${FENCED:?}"
for c in $C/*/*; do
  a=$(OUT=/tmp/r11u172_grid/P $D/case.sh $c $1 | sed 's/^[^ ]* //')
  b=$(OUT=/tmp/r11u172_grid/L $D/case.sh $c $2 | sed 's/^[^ ]* //')
  printf '%s\n   pristine: %s\n   law:      %s\n' "${c#$C/}" "$a" "$b"
done
