#!/bin/bash
# produce one row's database with a binary into /tmp/r11u183_W2/db/<test>.<tag>.uhdm (fence-refusing)
set -u; t=$1 bin=$2 tag=$3; shift 3
FENCED="$(grep -m1 '^FENCED=' /tmp/wt_r11u183/tools/probe/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || exit 3; for f in $FENCED; do [ "$t" = "$f" ] && exit 3; done
d=$(ls -d ${ROWSWEEP:-/tmp/r11u183_swL}/surelog/default/$t-* | head -1)
cwd=$(python3 -c "import sys; sys.path.insert(0,'/tmp/wt_r11u183/scripts'); import verify_golden as vg; print(vg.discover_surelog('^$t\$')['$t'][0])")
line=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *//'); args=$(python3 -c "import shlex,sys; a=shlex.split(sys.argv[1]); print(shlex.join(a[1:-2]))" "$line")
mkdir -p /tmp/r11u183_W2/db; O=/tmp/r11u183_W2/db/$t.$tag.uhdm; rm -f $O
( cd "$cwd" && eval env "$@" "$bin" $args -o $O > /dev/null 2>&1 </dev/null )
g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
printf 'surelog\tdefault\t%s\t%s\t%s\tx\n' $t $g $O
