#!/bin/bash
# rowrun.sh <corpus/mode/test> <tag> <binary> [ENV=VAL ...]: re-export one corpus row with the slang arguments the
# HEAD sweep recorded (cmds.txt of /tmp/r11u182_swH), under the given switches, into /tmp/r11u182_rows/<row>/<tag>.uhdm;
# prints the md5 and rc.  FAIL-CLOSED on $FENCED (drivers/env.sh): refuses without the four names, refuses a fenced row.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "rowrun.sh: source drivers/env.sh (FENCED)" >&2; exit 2; }
K=$1; t=$2; b=$3; shift 3
for f in $FENCED; do echo "$K" | grep -qw -- "$f" && { echo "rowrun.sh: fenced row refused" >&2; exit 2; }; done
C=${K%%/*}; r=${K#*/}; M=${r%%/*}; T=${r#*/}
cm=$(ls -d /tmp/r11u182_swH/$C/$M/$T-*/cmds.txt 2>/dev/null | head -1); [ -n "$cm" ] || { echo "$K no cmds"; exit 1; }
args=$(grep '^slang:' $cm | sed 's/^slang: *[^ ]* //; s/ -o [^ ]*$//')
if [ $C = uhdm2rtlil ]; then cwd=$UHDM2RTLIL_TESTS/$T; else cwd=$(dirname $(find $SURELOG_ROOT/tests $SURELOG_ROOT/third_party/tests -name "$T.sl" | head -1)); fi
O=/tmp/r11u182_rows/$C.$M.$T; mkdir -p $O; rm -f $O/$t.uhdm
(cd $cwd && env "$@" timeout 900 $b $args -o $O/$t.uhdm > $O/$t.log 2>&1 </dev/null); rc=$?
g=$(grep -o 'golden cache [a-z]* [^)]*' $cm | awk '{print $4}'); ln -sfn $(find $g -name '*.uhdm' | head -1) $O/golden.uhdm
echo "$K $t rc=$rc md5=$(md5sum < $O/$t.uhdm | cut -c1-12)"
