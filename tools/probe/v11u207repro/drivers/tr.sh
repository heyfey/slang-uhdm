#!/bin/bash
# fired laws on one case (law binary LB), view by ELAB
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"; D=$(cd "$1" && pwd); SRC=dut.sv; [ -f "$D/args" ] && SRC=$(cat "$D/args")
T=$(mktemp -d /tmp/v11u207_tr.XXXX); ( cd $D && R11U207_TRACE=$T ${LB:-/tmp/v11u207_bin/law.bin} $SRC --single-unit --nobuiltin ${ELAB:+--elabuhdm} -o $T/x.uhdm >/dev/null 2>&1 )
cat $T/*.T207 2>/dev/null | grep -v '^OUT' | sort | uniq -c | tr '\n' ';'; echo; rm -rf $T
