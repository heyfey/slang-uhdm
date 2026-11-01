#!/bin/bash
# sdist.sh <casedir>...: strict-record multiset distance golden-vs-pristine and golden-vs-law
# (records from uhdm-strictcmp --dump-a/--dump-b, file column path-normalized; counts golden-only + ours-only records)
source /tmp/wt_v11u460/tools/probe/v11u460repro/drivers/env.sh || exit 1
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/v11u460_runs$c
  for t in pris law ver; do [ -f $W/$t.uhdm ] || continue;
    FORCE2=1 /tmp/v11u460_tools/sc2 --max 1 --dump-a $W/sg.rec --dump-b $W/s$t.rec $W/sl/slpp_all/surelog.uhdm $W/$t.uhdm >/dev/null 2>&1
    sed -E 's#[^\t]*/##' $W/sg.rec | sort > $W/sg.srt; sed -E 's#[^\t]*/##' $W/s$t.rec | sort > $W/s$t.srt
    eval d_$t=$(( $(comm -23 $W/sg.srt $W/s$t.srt | wc -l) + $(comm -13 $W/sg.srt $W/s$t.srt | wc -l) ))
  done
  echo "${c#*/cases/} sdist pris=$d_pris law=$d_law ver=$d_ver grecs=$(wc -l < $W/sg.rec)"
done
