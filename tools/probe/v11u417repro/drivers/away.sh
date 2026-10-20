#!/bin/bash
# v11u417 away.sh: normalized-dump census of kept sv-tests databases, law workdir vs master's control
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
cd /tmp/v11u417swL/svtests
find . -name slang.uhdm | sort | while read p; do
  a=$(timeout 300 $D $p 2>/dev/null | tail -n +2 | sed 's#/tmp/v11u417swL#WD#g; s/, id:[0-9]*//g; s/ \[[0-9]*\]//' | md5sum | cut -c1-12)
  b=$(timeout 300 $D /tmp/intr11u415/svtests/$p 2>/dev/null | tail -n +2 | sed 's#/tmp/intr11u415#WD#g; s/, id:[0-9]*//g; s/ \[[0-9]*\]//' | md5sum | cut -c1-12)
  echo "$([ $a = $b ] && echo SAME || echo DIFF) $a $b $p"
done > /tmp/v11u417_away.txt
echo done >> /tmp/v11u417_away.txt
