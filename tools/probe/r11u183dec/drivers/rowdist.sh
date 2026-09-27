#!/bin/bash
# r11u183: the order-blind distance (obdist.py) of ONE corpus row-mode re-run with a given binary + env switches
# (the per-switch attribution of a mover).  The command line and the golden are read from a sweep workdir's cmds.txt.
# usage: rowdist.sh <sweep workdir> <corpus> <mode> <test> <binary> [VAR=1 ...]   (refuses the four fenced names)
set -u; S=$1 c=$2 m=$3 t=$4 bin=$5; shift 5
HERE=$(cd "$(dirname "$0")" && pwd)
FENCED="$(grep -m1 '^FENCED=' "$HERE/../../r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || exit 3; for f in $FENCED; do [ "$t" = "$f" ] && { echo refused; exit 3; }; done
d=$(ls -d "$S/$c/$m/$t"-* | head -1); g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
cwd=$(python3 - "$t" "$c" <<'PY'
import sys; sys.path.insert(0,'/tmp/wt_r11u183/scripts'); import verify_golden as vg
t,c=sys.argv[1:3]
tests = vg.discover_surelog('^'+t+'$') if c=='surelog' else vg.discover_uhdm2rtlil('^'+t+'$')
print(tests[t][0])
PY
)
line=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *//'); args=$(python3 -c "import shlex,sys; a=shlex.split(sys.argv[1]); print(shlex.join(a[1:-2]))" "$line")
T=/tmp/r11u183_rowdist_$$; mkdir -p $T; rm -f $T/o.uhdm
( cd "$cwd" && eval env "$@" "$bin" $args -o $T/o.uhdm > /dev/null 2>&1 </dev/null )
/tmp/r11u183_bin/uhdm-strictcmp --max 0 --dump-a $T/a --dump-b $T/b $g $T/o.uhdm > $T/s.txt 2>&1
[ -s $T/a ] || { $UHDM_CMP $g $T/o.uhdm 2>&1 | head -${CMPHEAD:-0}; }
echo "$t/$m [$(basename $bin) $*] $(python3 $HERE/obdist.py $T/a $T/b) md5=$(md5sum < $T/o.uhdm | cut -c1-12) $(grep -m1 -E '^(STRICT_|NOT_)' $T/s.txt)"
rm -rf $T
