#!/bin/bash
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo no dump; exit 2; }
cd /tmp/v11u427swL/svtests && find . -name slang.uhdm | sort > /tmp/v11u427_scr/kept.txt
while read p; do
 a=$(timeout 900 nice $D /tmp/v11u427swL/svtests/$p 2>/dev/null | sed 's#/tmp/v11u427sw[LV]#WD#g' | md5sum | cut -c1-12)
 b=$(timeout 900 nice $D /tmp/v11u427swV/svtests/$p 2>/dev/null | sed 's#/tmp/v11u427sw[LV]#WD#g' | md5sum | cut -c1-12)
 echo "$p L=$a V=$b $([ $a = $b ] && echo same || echo DIFF)"
done < /tmp/v11u427_scr/kept.txt
echo DUMPDONE
