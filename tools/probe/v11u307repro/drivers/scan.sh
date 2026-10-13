#!/bin/bash
# v11u307 scan.sh <binary> <out> : the firing scan of every case dir under tools/probe (dut.sv / dut.v, or the
# dir's args file), default view, under R11U307_TRACE; one line per dir that logs any pass-307 tag:
# <dir> <tag:count>...  The path list is built first and filtered by $FENCED (word boundary) before any case is
# opened; fail-closed.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "scan.sh: FENCED unset" >&2; exit 2; }
BIN=$1; OUT=$2; [ -x "$BIN" ] || { echo "scan.sh: binary not executable" >&2; exit 2; }
H=$(cd "$(dirname "$0")/../.." && pwd); fre=$(echo $FENCED | tr ' ' '|')
W=$(mktemp -d /tmp/v11u307_scan.XXXXXX); export W BIN
find $H \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##' | sort -u | grep -vwE "$fre" > $W/dirs
wc -l < $W/dirs >&2
xargs -P 3 -I{} bash -c 'c={}; h=$(echo "$c" | md5sum | cut -c1-12); mkdir -p $W/t/$h;
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args);
  (cd $c && R11U307_TRACE=$W/t/$h timeout 120 $BIN $SRC --single-unit --nobuiltin -o $W/t/$h/o.uhdm >/dev/null 2>&1);
  rm -f $W/t/$h/o.uhdm;
  if ls $W/t/$h/*.307 >/dev/null 2>&1; then echo "$c $(grep -hv ^OUT $W/t/$h/*.307 | cut -d" " -f1 | sort | uniq -c | awk "{printf \"%s:%s \", \$2, \$1}")"; fi;
  rm -rf $W/t/$h' < $W/dirs > $OUT
rm -rf $W
