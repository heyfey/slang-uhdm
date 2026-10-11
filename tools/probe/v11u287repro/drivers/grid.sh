#!/bin/bash
# v11u287 grid.sh <listfile of case dirs> <out> [jobs]: every case in both views on pristine (P), the delivered law (L),
# the law with R11U287_OFF (O), the verified fix (F), the fix with R11V287_OFF (V) and the fix with R11U287_OFF (FO);
# one case.sh line each (exit code included). Binaries in $B (pris, law, fix), scratch $S; the pins and $FENCED come
# from tools/probe/r11u287repro/drivers/env.sh (fail closed).
H=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$H/../../../.." && pwd); D=$REPO/tools/probe/r11u287repro/drivers
. $D/env.sh || exit 2
job(){ c=$1; for el in 0 1; do
  EL=$el bash $D/case.sh $c P $B/pris; EL=$el bash $D/case.sh $c L $B/law; EL=$el bash $D/case.sh $c O $B/law R11U287_OFF=1
  EL=$el bash $D/case.sh $c F $B/fix; EL=$el bash $D/case.sh $c V $B/fix R11V287_OFF=1; EL=$el bash $D/case.sh $c FO $B/fix R11U287_OFF=1
done; }
export -f job; export D
xargs -P ${3:-3} -I{} bash -c 'job {}' < $1 > $2 2>&1
