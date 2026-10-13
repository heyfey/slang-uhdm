#!/bin/bash
# (v11u317: copied from r11u317repro/drivers; rel maps v11u317repro/cases to v/)
# (r11u317: copied from v11u315repro/drivers)
# (r11u315: copied from r11u313repro/drivers)
# (r11u313: copied from v11u311repro/drivers)
# (v11u311: copied from r11u311repro/drivers)
# (r11u311: copied from r11u309repro/drivers)
# r11u313 firescan.sh (from r11u311, r11u307) <binary> <outdir>: the firing scan. Every tools/probe dut.sv of this checkout, the path list
# filtered by $FENCED (word boundary, read from tools/probe/r11u107repro/canaudit.sh, fail closed) BEFORE any file is
# opened, run under R11U317_TRACE; prints the dirs whose trace holds a writing tag (no *_ABSTAIN) to <outdir>/firing.txt.
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "firescan.sh: FENCED not 4 names" >&2; exit 2; }
FENCED_RE=$(echo $FENCED | tr ' ' '|')
BIN=$1; OUT=$2; [ -x "$BIN" ] || { echo "firescan.sh: binary not executable" >&2; exit 2; }
rm -rf $OUT; mkdir -p $OUT/t $OUT/o
cd $REPO/tools/probe
find . -name dut.sv | grep -vwE "$FENCED_RE" | sort > $OUT/list.txt
run1() { d=$(dirname "$1"); k=$(echo "$d" | tr '/' '_'); mkdir -p $OUT/t/$k; (cd "$d" && R11U317_TRACE=$OUT/t/$k timeout 120 $BIN dut.sv --single-unit --nobuiltin -o $OUT/o/$k.uhdm >/dev/null 2>&1; echo "$? $d" >> $OUT/rc.txt); rm -f $OUT/o/$k.uhdm; if cat $OUT/t/$k/* 2>/dev/null | grep -v '^OUT ' | grep -qv '_ABSTAIN'; then echo "$d"; fi; rm -rf $OUT/t/$k; }
export -f run1; export BIN OUT
xargs -a $OUT/list.txt -P ${FSJOBS:-2} -I{} bash -c 'run1 {}' > $OUT/firing.txt
sort -o $OUT/firing.txt $OUT/firing.txt
wc -l < $OUT/list.txt; wc -l < $OUT/firing.txt
