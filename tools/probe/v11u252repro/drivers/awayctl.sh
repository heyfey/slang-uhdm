#!/bin/bash
# (v11u252: copied from r11u252repro/drivers; TAGB=<tag> compares pristine with that tag's databases, default law)
# (r11u252) awayctl.sh <controls.txt-like file>: the away census of every case-view that moves between pristine and
# law and does not enter STRICT_EQUAL: every pair through drivers/awaychain.py (chain-keyed and flat records, $SCX,
# each database walked against itself), a stage-1 pair also through drivers/awaydump.py (uhdm-dump lines). Reads only
# the case.sh scratch tree under $S/g (case dumps; no corpus path). Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] && [ -n "$S" ] || { echo "awayctl.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); REPO=$(cd "$H/../../.." && pwd)
python3 - "$1" <<'PY' | while read -r cv st; do
import sys,collections,os
TB=os.environ.get("TAGB","law")
d=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f=l.split(); kv=dict(x.split('=',1) for x in f[2:] if '=' in x)
    if f[1] in ("pristine",TB): d[f[0]][f[1]]=(kv.get('strict',f[2]),kv.get('md5','-'))
for cv,t in sorted(d.items()):
    p,w=t.get('pristine'),t.get(TB)
    if p and w and p[1]!=w[1] and not w[0].startswith('STRICT_EQUAL'): print(cv, w[0])
PY
  for n in $FENCED; do echo "$cv" | grep -qw "$n" && { echo "$cv FENCED-REFUSED"; continue 2; }; done
  w=$S/g/$cv; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1)
  [ -n "$g" ] || { echo "$cv NOGOLDEN"; continue; }
  # every pair through the chain-keyed records (each database walked against itself, so a stage-1 pair is
  # keyed too); a stage-1 pair also through the order-blind uhdm-dump line census
  echo "$cv $st $(python3 $H/drivers/awaychain.py $g $w/pristine.uhdm $w/${TAGB:-law}.uhdm | head -1)"
  [ "$st" = NOT_EQUAL_stage1 ] && echo "$cv dumplines $(python3 $H/drivers/awaydump.py $g $w/pristine.uhdm $w/${TAGB:-law}.uhdm | head -1)"
done
