#!/bin/bash
# an.sh <sweep workdir> <out dir> <mode> <test>...: map 13's analyzer (tools/probe/r11u211map/drivers/analyze.py) on
# corpus rows of one sweep: strictcmp_x --max 50 record dumps, the analyzer's per-object facets, then clusters.py's
# tally by map 13's cluster id. Fenced names refused (fail-closed on $FENCED).
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "an.sh: source drivers/env.sh" >&2; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
W=$1; O=$2; m=$3; shift 3; mkdir -p $O/surelog/$m $O/tmp; : > $O/jobs.tsv
for t in "$@"; do
  for f in $FENCED; do [ "$f" = "$t" ] && continue 2; done
  d=$(ls -d $W/surelog/$m/$t-* $W/$m/$t-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || continue
  g=$(grep -o 'goldens/[0-9a-f]*' $d/cmds.txt | head -1); gd=$HOME/.cache/slang-uhdm-goldens/${g#goldens/}
  $B/strictcmp_x --max 50 --dump-a $O/surelog/$m/$t.a --dump-b $O/surelog/$m/$t.b $gd/golden.uhdm $d/slang.uhdm > $O/surelog/$m/$t.out 2>&1
  echo "rc=$?" >> $O/surelog/$m/$t.out
  printf "surelog\t$m\t$t\t$gd/golden.uhdm\t$d/slang.uhdm\tx\n" >> $O/jobs.tsv
done
R11U138_TMP=$O/tmp python3 $REPO/tools/probe/r11u211map/drivers/analyze.py $O/jobs.tsv $O/out.jsonl $O 2
python3 $HERE/clusters.py $O/out.jsonl
