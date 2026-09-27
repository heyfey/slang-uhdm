#!/bin/bash
# case.sh <casedir> [binary] : golden (pinned Surelog, the probe harness's arguments, own content-keyed cache) vs
# ours; prints "<case> rc= cmp= cmplines= strict=<verdict> | fields"; leaves golden.uhdm ours.uhdm a.rec b.rec
# strict.txt in $OUT/<case-key>[.$TAG]/ . Refuses a fenced path (fail closed on $FENCED).
set -u
. /tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh || exit 2
C=$(readlink -f $1); BIN=${2:-$SLANG_UHDM}
for f in $FENCED; do echo "$C" | grep -qw "$f" && { echo "fenced path refused"; exit 3; }; done
FILES=$( [ -f $C/files ] && cat $C/files || echo dut.sv )
KEY=$(cd $C && cat $FILES | sha1sum | cut -c1-16)-$(echo "$FILES" | tr '\n' ' ' | sha1sum | cut -c1-6)
GC=${GCACHE:-/tmp/r11u180_gold}/$KEY; mkdir -p $GC
if [ ! -s $GC/golden.uhdm ]; then
  rm -rf $GC/w; mkdir -p $GC/w
  (cd $C && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv $FILES -mt 0 -mp 0 -o $GC/w > $GC/surelog.log 2>&1)
  g=$(find $GC/w -name '*.uhdm' | head -1); [ -n "$g" ] && cp $g $GC/golden.uhdm; rm -rf $GC/w
fi
O=${OUT:-/tmp/r11u180_scr/caseout}/$(echo $C | sed 's|.*/cases/||; s|/|__|g')${TAG:+.$TAG}; mkdir -p $O; rm -f $O/ours.uhdm
(cd $C && timeout 300 $BIN $FILES --single-unit --nobuiltin -o $O/ours.uhdm > $O/slang.log 2>&1); rc=$?
[ -s $GC/golden.uhdm ] || { echo "$(echo $C | sed 's|.*/cases/||') SURELOG_FAIL"; exit 0; }
[ -s $O/ours.uhdm ] || { echo "$(echo $C | sed 's|.*/cases/||') SLANG_FAIL rc=$rc"; exit 0; }
cp $GC/golden.uhdm $O/golden.uhdm
$UHDM_CMP $O/golden.uhdm $O/ours.uhdm > $O/cmp.txt 2>&1; crc=$?
$STRICT_CMP --max ${MAX:-50} --dump-a $O/a.rec --dump-b $O/b.rec $O/golden.uhdm $O/ours.uhdm > $O/strict.txt 2>&1; src=$?
echo "$(echo $C | sed 's|.*/cases/||') rc=$rc cmp=$crc cmplines=$(wc -l < $O/cmp.txt) strict=$src $(tail -1 $O/strict.txt) | $(grep '^fields' $O/strict.txt)"
