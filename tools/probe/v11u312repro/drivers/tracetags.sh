#!/bin/bash
# v11u312 tracetags.sh <movers file> <cases root> <law bin>: for each mover case-view, the R11U312_TRACE tags its law run
# wrote (firings only; _ABSTAIN and _OFF lines dropped): `<case> <view> <tag>:<n> ...`.  Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "tracetags: FENCED unset" >&2; exit 2; }
M=$1; CR=$(cd "$2" && pwd); B=$3; [ -x "$B" ] || exit 2; T=/tmp/v11u312_tt.$$
grep '^MOVER' $M | while read -r _ c v _; do v=${v%:}; d=$CR/$c
  for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo fenced >&2; exit 2; }; done
  rm -rf $T; mkdir -p $T/t; ex=""; [ $v = e ] && ex="--elabuhdm"
  (cd $d && R11U312_TRACE=$T/t $B dut.sv --single-unit --nobuiltin $ex -o $T/o.uhdm >/dev/null 2>&1 </dev/null)
  echo "$c $v $(cat $T/t/* 2>/dev/null | grep -v '^OUT' | cut -d' ' -f1 | grep -vE '_(ABSTAIN|OFF)$' | sort | uniq -c | awk '{printf "%s:%s ", $2, $1}')"
done
rm -rf $T
