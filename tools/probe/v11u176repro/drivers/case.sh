#!/bin/bash
# case.sh <casedir> <tag> <bin> [env assignments via env]: golden (pinned Surelog, probe args, content-keyed cache) vs ours
set -u
source /tmp/v11u176_env.sh
C=$(readlink -f $1); TAG=$2; BIN=$3
for f in $FENCED; do echo "$C" | grep -qw "$f" && { echo "fenced path refused"; exit 3; }; done
FILES=$( [ -f $C/files ] && cat $C/files || echo dut.sv )
KEY=$(cd $C && cat $FILES | sha1sum | cut -c1-16)-$(echo "$FILES" | tr '\n' ' ' | sha1sum | cut -c1-6)
GC=/tmp/v11u176_gold/$KEY; mkdir -p $GC
if [ ! -s $GC/golden.uhdm ]; then
  rm -rf $GC/w; mkdir -p $GC/w
  (cd $C && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv $FILES -mt 0 -mp 0 -o $GC/w > $GC/surelog.log 2>&1 </dev/null)
  g=$(find $GC/w -name '*.uhdm' | head -1); [ -n "$g" ] && cp $g $GC/golden.uhdm; rm -rf $GC/w
fi
O=/tmp/v11u176_scr/caseout/$(echo $C | sed 's|/tmp/v11u176_cases/||; s|.*/tools/probe/||; s|/|__|g').$TAG; mkdir -p $O; rm -f $O/ours.uhdm
(cd $C && timeout 300 $BIN $FILES --single-unit --nobuiltin -o $O/ours.uhdm > $O/slang.log 2>&1 </dev/null); rc=$?
N=$(echo $C | sed 's|/tmp/v11u176_cases/||; s|.*/tools/probe/||')
[ -s $GC/golden.uhdm ] || { echo "$N $TAG SURELOG_FAIL"; exit 0; }
[ -s $O/ours.uhdm ] || { echo "$N $TAG SLANG_FAIL rc=$rc"; exit 0; }
$UHDM_CMP $GC/golden.uhdm $O/ours.uhdm > $O/cmp.txt 2>&1; crc=$?
$STRICT_CMP --max ${MAX:-30} --dump-a $O/a.rec --dump-b $O/b.rec $GC/golden.uhdm $O/ours.uhdm > $O/strict.txt 2>&1; src=$?
echo "$N $TAG rc=$rc cmp=$crc cmplines=$(wc -l < $O/cmp.txt) strict=$src $(grep -E 'STRICT_EQUAL|STRICT_NOTEQUAL|stage' $O/strict.txt | tail -1) md5=$(md5sum < $O/ours.uhdm | cut -c1-8)"
