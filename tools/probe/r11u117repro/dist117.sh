#!/bin/bash
# dist117.sh <out-root> <tagA> <tagB> — whole-dump distance to golden (sorted,
# path-normalised, ids dropped) per arm for two tags, and the A->B dump delta.
OUT=${1:?}; A=${2:?}; B=${3:?}
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
norm() { python3 "$(dirname "$0")/norm117.py" "$1" | sort; }
for w in "$OUT"/*/; do a=$(basename "$w"); [ -f "$w/gold.uhdm" ] || continue
  for t in gold "$A" "$B"; do [ -f "$w/$t.uhdm" ] || continue
    [ -s "$w/$t.dump" ] && [ "$w/$t.dump" -nt "$w/$t.uhdm" ] || $D "$w/$t.uhdm" > "$w/$t.dump" 2>&1
    norm "$w/$t.dump" > "$w/$t.norm"; done
  da=$(diff "$w/gold.norm" "$w/$A.norm" | grep -c '^[<>]'; true)
  db=$(diff "$w/gold.norm" "$w/$B.norm" | grep -c '^[<>]'; true)
  dab=$(diff "$w/$A.norm" "$w/$B.norm" | grep -c '^[<>]'; true)
  echo "$a dist_$A=$da dist_$B=$db delta=$dab $([ $db -lt $da ] && echo TO) $([ $db -gt $da ] && echo AWAY)"
done
