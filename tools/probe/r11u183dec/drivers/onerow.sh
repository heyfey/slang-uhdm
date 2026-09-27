#!/bin/bash
# r11u183: re-run ONE corpus row-mode of a sweep workdir with a given binary + env, judge with uhdm-cmp.
# usage: onerow.sh <sweep workdir> <corpus> <mode> <test> <binary> [VAR=1 ...]   (fence-refusing)
set -u; S=$1 c=$2 m=$3 t=$4 bin=$5; shift 5
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh"
FENCED="$(grep -m1 '^FENCED=' "$HERE/../../r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || exit 3; for f in $FENCED; do [ "$t" = "$f" ] && { echo refused; exit 3; }; done
d=$(ls -d "$S/$c/$m/$t"-* | head -1); g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
case $c in surelog) root=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog;; *) root=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test;; esac
line=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *//'); args=$(python3 -c "import shlex,sys; a=shlex.split(sys.argv[1]); print(shlex.join(a[1:-2]))" "$line")
cwd=$(python3 - "$t" "$c" <<'PY'
import sys; sys.path.insert(0,'/tmp/wt_r11u183/scripts'); import verify_golden as vg
t,c=sys.argv[1:3]
tests = vg.discover_surelog('^'+t+'$') if c=='surelog' else vg.discover_uhdm2rtlil('^'+t+'$')
print(tests[t][0])
PY
)
O=/tmp/r11u183_onerow_$$.uhdm; rm -f $O
( cd "$cwd" && eval env "$@" "$bin" $args -o $O > /dev/null 2>&1 </dev/null )
${UHDM_CMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp} $g $O > /dev/null 2>&1; r=$?
s=$(/tmp/r11u183_bin/uhdm-strictcmp --max 0 $g $O 2>/dev/null | grep -E '^(STRICT_|NOT_)'); echo "$t/$m [$*] cmp_rc=$r $s"; rm -f $O
