#!/bin/bash
# census wrapper: runs ver1.bin with R11U163_TRACE=1, logs OVLOCALREF firings with cwd + args
R11U163_TRACE=1 /tmp/v11u163_bin/ver1.bin "$@" 2> >(tee /tmp/v11u163_cen_err_$$.txt >&2)
rc=$?
wait
n=$(grep -c 'R11U163_TRACE OVLOCALREF' /tmp/v11u163_cen_err_$$.txt 2>/dev/null)
[ "${n:-0}" -gt 0 ] && echo "OVLOCALREF $n $(pwd) $*" >> /tmp/v11u163_census.log
rm -f /tmp/v11u163_cen_err_$$.txt
exit $rc
