#!/bin/bash
# case.sh <casedir> : golden (pinned Surelog, probe args, content-keyed cache) vs pris and law; one line per binary
set -u
source /tmp/v11u171_scr/env.sh
C=$(readlink -f $1)
for f in $FENCED; do echo "$C" | grep -qw "$f" && { echo "fenced path refused"; exit 3; }; done
FILES=$( [ -f $C/files ] && cat $C/files || echo dut.sv )
KEY=$(cd $C && cat $FILES | sha1sum | cut -c1-16)-$(echo "$FILES" | tr '\n' ' ' | sha1sum | cut -c1-6)
GC=/tmp/v11u171_gold/$KEY; mkdir -p $GC
if [ ! -s $GC/golden.uhdm ]; then
  rm -rf $GC/w; mkdir -p $GC/w
  (cd $C && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv $FILES -mt 0 -mp 0 -o $GC/w > $GC/surelog.log 2>&1 </dev/null)
  g=$(find $GC/w -name '*.uhdm' | head -1); [ -n "$g" ] && cp $g $GC/golden.uhdm; rm -rf $GC/w
fi
name=$(echo $C | sed 's|.*/v11u171_cases/||')
for b in ${BINS:-pris law}; do
  O=/tmp/v11u171_caseout/$(echo $name | tr / _).$b${TAG:+.$TAG}; mkdir -p $O; rm -f $O/ours.uhdm
  (cd $C && timeout 300 env ${EXTRA_ENV:-X171=1} /tmp/v11u171_bin/$b.bin $FILES --single-unit --nobuiltin -o $O/ours.uhdm > $O/slang.log 2>&1 </dev/null); rc=$?
  [ -s $GC/golden.uhdm ] || { echo "$name SURELOG_FAIL"; exit 0; }
  [ -s $O/ours.uhdm ] || { echo "$name $b SLANG_FAIL rc=$rc"; continue; }
  $UHDM_CMP $GC/golden.uhdm $O/ours.uhdm > $O/cmp.txt 2>&1; crc=$?
  /tmp/v11u171_bin/uhdm-strictcmp --max ${MAX:-50} --dump-a $O/a.rec --dump-b $O/b.rec $GC/golden.uhdm $O/ours.uhdm > $O/strict.txt 2>&1; src=$?
  printf "%-40s %-4s rc=%s cmp=%s/%s strict=%s %s | %s\n" "$name" $b $rc $crc $(wc -l < $O/cmp.txt) $src "$(tail -n 1 $O/strict.txt)" "$(grep '^fields' $O/strict.txt)"
done
