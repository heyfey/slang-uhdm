#!/bin/bash
# sw.sh <absolute casedir>: md5 for pristine and fix1 under each switch set
d=$1; w=/tmp/v11u169_swc/$(echo $d | md5sum | cut -c1-10); mkdir -p $w
line="$d"
run(){ o=$w/$1.uhdm; rm -f $o; (cd $d && env $2 $3 dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); echo -n " $1:$?:$( [ -s $o ] && md5sum < $o | cut -c1-10 || echo none)"; }
line="$line$(run P X=1 /tmp/v11u169_bin/pris)$(run F X=1 /tmp/v11u169_bin/fix1)$(run G R11U169_GCACHAIN_OFF=1 /tmp/v11u169_bin/fix1)$(run M 'R11U169_MLLOC_OFF=1 R11U169_MLARGLOC_OFF=1' /tmp/v11u169_bin/fix1)$(run m1 R11U169_MLLOC_OFF=1 /tmp/v11u169_bin/fix1)$(run m2 R11U169_MLARGLOC_OFF=1 /tmp/v11u169_bin/fix1)$(run Q R11U169_PATFLATSPAN_OFF=1 /tmp/v11u169_bin/fix1)$(run I R11V169_INSIDESET_OFF=1 /tmp/v11u169_bin/fix1)"
echo "$line"
