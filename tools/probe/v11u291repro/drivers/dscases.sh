#!/bin/bash
# v11u291 dscases.sh <out> <tags> <case dir>...: the downstream harness on each case with $B/<tag> for each tag
# (r11u291repro/drivers/dscases.py, fail-closed on $FENCED). Export B and S.
D=$(cd "$(dirname "$0")/../../r11u291repro/drivers" && pwd); . "$D/env.sh" || exit 2
out=$1; tags=$2; shift 2
for t in $tags; do SLANG_UHDM=$B/$t python3 $D/dscases.py $t $S/ds "$@"; done > $out 2>&1
