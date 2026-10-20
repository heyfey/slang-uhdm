#!/bin/bash
# v11u415 vcheck.sh <out> <case>...: ver vs law, ver+R11V415_OFF vs law, ver per-refinement switch vs law (rc:dumpmd5:size)
V=${VERBIN:-/tmp/v11u415_bin/ver1}; L=/tmp/v11u415_bin/law; OUT=$1; shift
m() { echo "$1" | sed 's/.*rc=\([0-9]*\).*dmd5=\([0-9a-f]*\) sz=\([0-9]*\).*/\1:\2:\3/'; }
for c in "$@"; do c=$(readlink -f $c)
 l=$(bash /tmp/v11u415_drv/case.sh $c $L); v=$(bash /tmp/v11u415_drv/case.sh $c $V); o=$(bash /tmp/v11u415_drv/case.sh $c $V R11V415_OFF=1)
 echo "$(basename $(dirname $c))/$(basename $c) | L ${l#* } | V ${v#* } | ver=law:$([ "$(m "$v")" = "$(m "$l")" ] && echo y || echo N) VOFF=law:$([ "$(m "$o")" = "$(m "$l")" ] && echo y || echo N)" >> $OUT
done
