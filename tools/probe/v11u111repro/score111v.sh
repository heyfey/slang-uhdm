#!/bin/bash
# <out-root> <tagA> <tagB>: per arm whose A/B bytes differ: ctxdist gold/A/B + cmp counts
O=$1; A=$2; B=$3; D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump; PY=$(cd "$(dirname "$0")/../r11u111repro" && pwd)/ctxdist111.py
for g in $(find "$O" -name gold.uhdm | sort); do
  w=$(dirname "$g"); [ -f "$w/$A.uhdm" ] && [ -f "$w/$B.uhdm" ] || continue
  cmp -s "$w/$A.uhdm" "$w/$B.uhdm" && continue
  for t in gold $A $B; do timeout 600 "$D" "$w/$t.uhdm" 2>/dev/null | sed -E 's#'"$w"'##g' > "$w/$t.dump"; done
  r=$(python3 $PY "$w/gold.dump" "$w/$A.dump" "$w/$B.dump" 0 | tr '\n' ' ')
  ca=$(wc -l < $w/$A.cmp); cb=$(wc -l < $w/$B.cmp)
  echo "${w#$O/} cmp $ca->$cb $r"
done
