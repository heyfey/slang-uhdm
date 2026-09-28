#!/bin/bash
# offcheck.sh <pristine bin> <law bin> <out>: the whole-pass switch check.  Every tests/probe case, every case of this
# directory's cases/ is exported by the pristine binary and by the law binary under R11U192_OFF=1 alone; the two
# databases must be byte-identical.  Fence-refusing (a case path
# naming a fenced test is skipped and counted).  3 parallel jobs.
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
FENCED="$(sed -n 's/^FENCED="\(.*\)"$/\1/p' $REPO/tools/probe/r11u107repro/canaudit.sh)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "offcheck: fence unreadable" >&2; exit 3; }
FRE="\\b($(echo $FENCED | tr ' ' '|'))\\b"
P=$1; L=$2; O=$3; T=/tmp/r11u192_off; rm -rf $T; mkdir -p $T
( find $REPO/tests/probe $HERE/../cases -name dut.sv -printf '%h\n' | sort ) > $T/list
grep -cP "$FRE" $T/list | sed 's/^/fenced_skipped=/'
grep -vP "$FRE" $T/list > $T/list2
one() { d=$1; k=$(echo "$d" | md5sum | cut -c1-16)
  (cd $d && $P dut.sv --single-unit --nobuiltin -o $T/$k.p > /dev/null 2>&1; cd $d && R11U192_OFF=1 $L dut.sv --single-unit --nobuiltin -o $T/$k.l > /dev/null 2>&1)
  if [ ! -e $T/$k.p ] && [ ! -e $T/$k.l ]; then echo "BOTHFAIL $d"; elif cmp -s $T/$k.p $T/$k.l; then echo "SAME $d"; else echo "DIFF $d"; fi; rm -f $T/$k.p $T/$k.l; }
export -f one; export P L T
xargs -P 3 -I{} bash -c 'one {}' < $T/list2 > $O
echo "cases=$(wc -l < $T/list2) same=$(grep -c ^SAME $O) diff=$(grep -c ^DIFF $O) bothfail=$(grep -c ^BOTHFAIL $O)"
