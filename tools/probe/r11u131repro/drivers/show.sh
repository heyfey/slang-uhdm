#!/usr/bin/env bash
# show.sh <case dir> <binary> : strictcmp records (--max 30) golden vs ours for one case
set -u
c=$(realpath $1); bin=$2
d=$(dirname "$(realpath "$0")")
o=/tmp/r11u131_show; mkdir -p $o
"$d/run_case.sh" "$c" "$bin" $o >/dev/null
name=$(echo "$c" | sed 's#.*/tools/probe/##; s#/#__#g')
"$STRICT_CMP" --max ${MAX:-30} "$(cat $o/$name.golden)" "$o/$name.uhdm"
