#!/bin/bash
# case.sh <casedir> <tag> <binary> : golden (probe-harness args, content-keyed cache) vs ours
set -u
. /tmp/v11u180_scr/env.sh || exit 2
C=$(readlink -f $1); TAG=$2; BIN=$3
for f in $FENCED; do echo "$C" | grep -qw "$f" && { echo "fenced path refused"; exit 3; }; done
FILES=$( [ -f $C/files ] && cat $C/files || echo dut.sv )
KEY=$(cd $C && cat $FILES | sha1sum | cut -c1-16)-$(echo "$FILES" | tr '\n' ' ' | sha1sum | cut -c1-6)
GC=/tmp/v11u180_gold/$KEY; mkdir -p $GC
if [ ! -s $GC/golden.uhdm ]; then
  rm -rf $GC/w; mkdir -p $GC/w
  (cd $C && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv $FILES -mt 0 -mp 0 -o $GC/w > $GC/surelog.log 2>&1)
  g=$(find $GC/w -name '*.uhdm' | head -1); [ -n "$g" ] && cp $g $GC/golden.uhdm; rm -rf $GC/w
fi
N=$(echo $C | sed 's|.*/v11u180_cases/||; s|/|__|g')
O=/tmp/v11u180_scr/out/$N.$TAG; mkdir -p $O; rm -f $O/ours.uhdm
(cd $C && timeout 300 $BIN $FILES --single-unit --nobuiltin -o $O/ours.uhdm > $O/slang.log 2>&1); rc=$?
[ -s $GC/golden.uhdm ] || { echo "$N $TAG SURELOG_FAIL"; exit 0; }
[ -s $O/ours.uhdm ] || { echo "$N $TAG SLANG_FAIL rc=$rc"; exit 0; }
cp $GC/golden.uhdm $O/golden.uhdm
$UHDM_CMP $O/golden.uhdm $O/ours.uhdm > $O/cmp.txt 2>&1; crc=$?
$STRICT_CMP --max ${MAX:-30} --dump-a $O/a.rec --dump-b $O/b.rec $O/golden.uhdm $O/ours.uhdm > $O/strict.txt 2>&1
echo "$N $TAG rc=$rc cmp=$crc cmpl=$(wc -l < $O/cmp.txt) md5=$(md5sum < $O/ours.uhdm | cut -c1-8) $(tail -1 $O/strict.txt)"
