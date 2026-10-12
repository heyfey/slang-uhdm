#!/bin/bash
# v11u290 rerow.sh <wd> <row> <mode> <binary> <out.uhdm> [ENV=VAL ...]: re-run one corpus row-mode's slang line
# from <wd>/surelog/<mode>/<row>-*/cmds.txt with another binary and output, in the row's source directory
# (Surelog tests tree). Fail-closed on $FENCED: a fenced row name is refused before any file is opened.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "rerow.sh: source drivers/env.sh (FENCED)" >&2; exit 2; }
wd=$1; row=$2; mode=$3; b=$4; out=$5; shift 5
for n in $FENCED; do [ "$row" = "$n" ] && { echo "rerow.sh: fenced row refused" >&2; exit 2; }; done
[ -x "$b" ] || { echo "rerow.sh: binary not executable: $b" >&2; exit 2; }
c=$(ls -d $wd/surelog/$mode/$row-* | head -1)/cmds.txt; [ -f "$c" ] || { echo "rerow.sh: no cmds.txt" >&2; exit 2; }
line=$(grep -m1 '^slang:' $c | sed 's/^slang: *//')
set -- "$@"; read -ra argv <<< "$line"; argv[0]=$b
for i in "${!argv[@]}"; do [ "${argv[$i]}" = "-o" ] && argv[$((i+1))]=$out; done
sl=$(find $SURELOG_ROOT/tests $SURELOG_ROOT/third_party/tests -name "$row.sl" | grep -vwE "$(echo $FENCED | tr ' ' '|')" | head -1)
[ -n "$sl" ] || { echo "rerow.sh: no .sl for $row" >&2; exit 2; }; d=$(dirname $sl)
rm -f $out; (cd $d && env "$@" timeout 900 "${argv[@]}" > $out.log 2>&1); echo "rc=$?"
