#!/bin/bash
# v11u317 firescanv.sh <binary> <outdir>: the firing scan with the tags kept. Every tools/probe dut.sv of this
# checkout, the path list filtered by $FENCED (word boundary, read from tools/probe/r11u107repro/canaudit.sh, fail
# closed) BEFORE any file is opened, run under R11U317_TRACE; <outdir>/fire.txt holds one line per firing dir with its
# writing tags (no *_ABSTAIN), <outdir>/rc.txt the exit code of every dir.
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "firescanv.sh: FENCED not 4 names" >&2; exit 2; }
FENCED_RE=$(echo $FENCED | tr ' ' '|')
BIN=$1; OUT=$2; [ -x "$BIN" ] || { echo "firescanv.sh: binary not executable" >&2; exit 2; }
[ -n "$OUT" ] || exit 2
rm -rf $OUT; mkdir -p $OUT/t $OUT/o
cd $REPO/tools/probe
find . -name dut.sv | grep -vwE "$FENCED_RE" | sort > $OUT/list.txt
run1() { d=$(dirname "$1"); k=$(echo "$d" | tr '/' '_'); mkdir -p $OUT/t/$k; (cd "$d" && R11U317_TRACE=$OUT/t/$k timeout 120 $BIN dut.sv --single-unit --nobuiltin -o $OUT/o/$k.uhdm >/dev/null 2>&1; echo "$? $d" >> $OUT/rc.txt); rm -f $OUT/o/$k.uhdm; tg=$(cat $OUT/t/$k/* 2>/dev/null | grep -v '^OUT ' | awk '{print $1}' | grep -v '_ABSTAIN$' | sort -u | tr '\n' ' '); [ -n "$tg" ] && echo "$d $tg"; rm -rf $OUT/t/$k; }
export -f run1; export BIN OUT
xargs -a $OUT/list.txt -P ${FSJOBS:-2} -I{} bash -c 'run1 {}' > $OUT/fire.txt
sort -o $OUT/fire.txt $OUT/fire.txt; sort -k2 -o $OUT/rc.txt $OUT/rc.txt
wc -l < $OUT/list.txt; wc -l < $OUT/fire.txt
