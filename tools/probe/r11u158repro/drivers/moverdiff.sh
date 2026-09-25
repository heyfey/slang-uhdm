#!/bin/bash
# moverdiff.sh <law workdir> <pristine workdir> <corpus> <mode> <name>: the strict comparator's
# differing records of the pristine and the law database of one corpus row against its golden;
# prints the counts that leave / enter and the entering records.  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "moverdiff.sh: export FENCED (four names) first" >&2; exit 1; }
L=$1; P=$2; C=$3; M=$4; n=$5
for f in $FENCED; do [ "$f" = "$n" ] && { echo "fenced: skipped"; exit 0; }; done
SC=${STRICT_CMP:-/tmp/r11u158_bin/uhdm-strictcmp}
dl=$(ls -d $L/$C/$M/$n-* | head -1); dp=$(ls -d $P/$C/$M/$n-* | head -1)
g=$(grep -o 'golden cache hit [^)]*' $dl/cmds.txt | awk '{print $4}')/golden.uhdm
[ -f "$g" ] || g=$(ls $dl/*.uhdm | grep -v slang.uhdm | head -1)
T=$(mktemp -d /tmp/r11u158_md.XXXX)
$SC --max 1000000 $g $dp/slang.uhdm > $T/p 2>&1; $SC --max 1000000 $g $dl/slang.uhdm > $T/l 2>&1
grep -E '^  [AB]:' $T/p | sort > $T/pr; grep -E '^  [AB]:' $T/l | sort > $T/lr
echo "$C/$M/$n: pristine [$(tail -1 $T/p)] law [$(tail -1 $T/l)] leave $(comm -23 $T/pr $T/lr | wc -l) enter $(comm -13 $T/pr $T/lr | wc -l)"
comm -13 $T/pr $T/lr | head -${SHOW:-4} | cut -c1-200
rm -rf $T
