#!/bin/bash
# r11u427 census.sh <pristine> <law> <out> <root>... : every fence-filtered case dir (a dut.sv) under the roots,
# both binaries, exit code + output md5; prints one line per case dir: path rcP rcL same|MOVED
P=$1; L=$2; OUT=$3; shift 3
S=/tmp/r11u427_scr/census; mkdir -p $S
find "$@" -name dut.sv -printf '%h\n' | sort -u > $S/all.lst
python3 - $S/all.lst $S/list.lst <<'PY'
import sys
F=[l.strip() for l in open('/tmp/r11u427_scr/fenced.txt') if l.strip()]
ds=[l.strip() for l in open(sys.argv[1]) if l.strip()]
open(sys.argv[2],'w').write('\n'.join(d for d in ds if not any(f in d for f in F))+'\n')
print(len(ds), 'listed', sum(1 for d in ds if not any(f in d for f in F)), 'after fence', file=sys.stderr)
PY
one() { c=$1; k=$(echo "$c" | md5sum | cut -c1-16); T=""; [ -f $c/TOP ] && T="--top $(cat $c/TOP)"
 r=""; for b in $P $L; do o=$S/$k.$(basename $b).uhdm; rm -f $o; (cd $c && timeout 300 $b dut.sv $T --single-unit --nobuiltin -o $o >/dev/null 2>&1 </dev/null); rc=$?; m=$( [ -f $o ] && md5sum < $o | cut -c1-12 || echo none); rm -f $o; r="$r $rc:$m"; done
 set -- $r; [ "$1" = "$2" ] && s=same || s=MOVED; echo "$c $r $s"; }
export -f one; export P L S
xargs -a $S/list.lst -P 3 -I{} bash -c 'one {}' > $OUT
echo "processed $(wc -l < $OUT) listed $(wc -l < $S/list.lst) moved $(grep -c ' MOVED$' $OUT)"
