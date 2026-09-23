#!/bin/bash
# r11u104 grid driver: run every arm in $G against one binary under one tag
# (R104OFF passes through for the exploration binary), then score BOTH keys
# (score104.py = the NET-NAME key over every cont_assign, loc97v.py = the
# five-field VIEW-KEYED location key) against the pristine tag.
# usage: G=<griddir> grid104.sh <tag> <binary> [pristine-tag]
set -u
G=${G:?grid dir}; TAG=$1; BIN=$2; P=${3:-pris}
H=$(dirname "$(readlink -f "$0")")
cd "$G" && ls *.sv | xargs -P 3 -I{} bash "$H/run104.sh" {} "$TAG=$BIN" > "$G/$TAG.log" 2>&1
awk '{print $3,$4,$5,$6}' "$G/$TAG.log" | sort | uniq -c
for a in $(ls *.sv | sed 's/\.sv$//'); do
  n=$(python3 "$H/score104.py" $a.g.dump $a.$P.dump $a.$TAG.dump | tail -1)
  l=$(python3 "$H/../r11u100repro/loc97v.py" $a.g.dump $a.$P.dump $a.$TAG.dump | grep VIEW-KEYED)
  echo "$a NAME[$n] LOC[$l]"
done > "$G/$TAG.score"
python3 - "$G/$TAG.score" <<'PY'
import re, sys
t = {}
for l in open(sys.argv[1]):
    for key in ('NAME', 'LOC'):
        m = re.search(key + r'\[([^\]]*)\]', l)
        if not m: continue
        for f in ('TO', 'AWAY', 'MWRONG'):
            n = re.search(r'\b' + f + r'=(\d+)', m.group(1))
            if n: t[key + f] = t.get(key + f, 0) + int(n.group(1))
print('TOTAL NAME TO=%d AWAY=%d MWRONG=%d | LOC TO=%d AWAY=%d MWRONG=%d' % tuple(
    t.get(k, 0) for k in ('NAMETO', 'NAMEAWAY', 'NAMEMWRONG', 'LOCTO', 'LOCAWAY', 'LOCMWRONG')))
PY
grep -E 'AWAY=[1-9]|MWRONG=[1-9]' "$G/$TAG.score" | cut -c1-80
