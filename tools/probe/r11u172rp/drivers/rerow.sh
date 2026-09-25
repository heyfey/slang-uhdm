#!/bin/bash
# rerow.sh <binary> <corpus> <mode> <test> <outdir> : re-export one corpus row with <binary>
# using the argument vector recorded in the pristine sweep's cmds.txt, then strict-compare.
# Refuses the fenced tests (fail closed).
set -u
BIN=$1 C=$2 M=$3 T=$4 O=$5
: "${FENCED:?FENCED unset: refuse}"; [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "FENCED not 4" >&2; exit 3; }
for f in $FENCED; do echo "$T" | grep -qw "$f" && { echo "FENCED $T refused" >&2; exit 3; }; done
REF=${REF:-/tmp/r11u172_swP}
cm=$(ls -d $REF/$C/$M/$T-*/cmds.txt 2>/dev/null | head -1)
[ -f "$cm" ] || { echo "no cmds for $C/$M/$T" >&2; exit 4; }
g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $cm | head -1)/golden.uhdm
args=$(grep '^slang:' $cm | sed 's/^slang: *[^ ]* //; s/ -o [^ ]*$//')
if [ $C = uhdm2rtlil ]; then cwd=$UHDM2RTLIL_TESTS/$T; else cwd=$(dirname $(ls $SURELOG_ROOT/tests/$T/$T.sl $SURELOG_ROOT/third_party/tests/$T/$T.sl 2>/dev/null | head -1)); fi
mkdir -p $O; rm -f $O/ours.uhdm
(cd $cwd && $BIN $args -o $O/ours.uhdm > $O/slang.log 2>&1); echo "rc=$?" > $O/rc
cp $g $O/golden.uhdm 2>/dev/null
${STRICT_CMP} --max ${MAX:-50} --dump-a $O/a.rec --dump-b $O/b.rec $O/golden.uhdm $O/ours.uhdm > $O/strict.txt 2>&1; echo "strict_rc=$?" >> $O/rc
echo "$C/$M/$T $(cat $O/rc | tr '\n' ' ') $(head -1 $O/strict.txt)"
