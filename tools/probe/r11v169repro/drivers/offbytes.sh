#!/bin/bash
# ob.sh <casedir-rel under tools/probe>: pris, fix1 OFF, fix1, law -> md5s
r=$1; d=/tmp/wt_v11u169/tools/probe/$r; w=/tmp/v11u169_ob/$r; mkdir -p $w
line="$r"
for t in P O F L; do
  case $t in P) b=/tmp/v11u169_bin/pris; e="";; O) b=/tmp/v11u169_bin/fix1; e="R11U169_OFF=1";; F) b=/tmp/v11u169_bin/fix1; e="";; L) b=/tmp/v11u169_bin/law; e="";; esac
  o=$w/$t.uhdm; rm -f $o
  (cd $d && env $e $b dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); rc=$?
  m=$( [ -s $o ] && md5sum < $o | cut -c1-12 || echo none)
  line="$line $t:$rc:$m"
done
echo "$line"
