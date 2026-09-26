#!/bin/bash
# bytes.sh <abs case dir> <bin> <outfile> : export with env as given, print md5
C=$1; FILES=$( [ -f $C/files ] && cat $C/files || echo dut.sv ); rm -f $3
(cd $C && timeout 120 $2 $FILES --single-unit --nobuiltin -o $3 >/dev/null 2>&1 </dev/null); echo "$C $( [ -s $3 ] && md5sum < $3 | cut -c1-12 || echo NODB)"
