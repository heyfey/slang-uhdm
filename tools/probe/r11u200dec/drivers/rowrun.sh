#!/bin/bash
# r11u200: re-run one corpus row-mode of the reference sweep (/tmp/intr11u199) with the binary $SLANG_UHDM, the
# sweep's own command line and cwd, into <out>/slang.uhdm, then strict-compare against the sweep's golden.
# usage: rowrun.sh <corpus> <mode> <test> <out dir>   (fence fail-closed: refuses the four FENCED names)
set -u
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
C=$1 M=$2 T=$3 O=$4
for f in $FENCED; do [ "$T" = "$f" ] && { echo "rowrun: fenced test refused" >&2; exit 3; }; done
D=$(ls -d /tmp/intr11u199/$C/$M/$T-* 2>/dev/null | head -1); [ -n "$D" ] || { echo "rowrun: no sweep dir"; exit 1; }
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)
line=$(grep '^slang:' $D/cmds.txt | sed 's/^slang: *//')
args=$(echo "$line" | cut -d' ' -f2- | sed "s# -o $D/slang.uhdm##")
if [ "$C" = uhdm2rtlil ]; then cwd=$UHDM2RTLIL_TESTS/$T; else
  sl=$(find $SURELOG_ROOT/tests $SURELOG_ROOT/third_party/tests -maxdepth 3 -name "$T.sl" 2>/dev/null | head -1); cwd=$(dirname "$sl"); fi
mkdir -p $O; rm -f $O/slang.uhdm
( cd $cwd && $SLANG_UHDM $args -o $O/slang.uhdm > $O/slang.log 2>&1; echo "rc=$?" >> $O/slang.log )
echo "slang: $SLANG_UHDM $args (cwd $cwd)" > $O/cmds.txt
$UHDM_CMP $G/golden.uhdm $O/slang.uhdm > $O/cmp.txt 2>&1; crc=$?
$SCMP --max ${MAX:-50} ${DUMPS:+--dump-a $O/a.rec --dump-b $O/b.rec} $G/golden.uhdm $O/slang.uhdm > $O/strict.txt 2>&1
echo "$C/$M/$T cmp=$crc $(tail -1 $O/strict.txt) $(grep -m1 '^fields' $O/strict.txt)"
