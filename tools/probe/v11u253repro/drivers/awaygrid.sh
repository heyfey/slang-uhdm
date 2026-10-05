#!/bin/bash
# (v11u253) awaygrid.sh <grid.txt>: the order-blind away census (away.py) of pristine -> law on every case-view of a
# grid whose bytes moved; one line per case-view. Needs drivers/env.sh sourced ($S, $FENCED, $STRICT_CMP).
[ -n "$FENCED" ] && [ -x "$STRICT_CMP" ] || { echo "awaygrid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd)
python3 - "$1" <<'PY' | grep -vwE "$FENCE_RE" | while read cv; do
import sys,collections
r=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f=l.split(); r[f[0]][f[1]]=dict(x.split('=',1) for x in f[2:] if '=' in x)
for c,v in sorted(r.items()):
    if v['pristine'].get('md5')!=v['law'].get('md5'): print(c)
PY
  w=$S/g/$cv; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1); [ -s "$g" ] || { echo "$cv NO_GOLDEN"; continue; }
  mkdir -p $w/away; echo "$cv $(python3 $H/away.py $g $w/pristine.uhdm $w/law.uhdm $w/away)"
done
