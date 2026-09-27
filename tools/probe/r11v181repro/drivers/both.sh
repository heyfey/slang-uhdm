#!/bin/bash
for c in "$@"; do for v in "" 1; do
  a=$(ELAB=$v /tmp/v11u181_grid.sh $c /tmp/v11u181_bin/pris.bin P)
  b=$(ELAB=$v /tmp/v11u181_grid.sh $c /tmp/v11u181_bin/law.bin L R11U181_TRACE=1)
  rel=$(echo "$a" | cut -d' ' -f1)
  sa=$(echo "$a" | grep -o 'cmplines=[0-9]* strict=[^ ]*'); sb=$(echo "$b" | grep -o 'cmplines=[0-9]* strict=[^ ]*')
  ma=$(echo "$a" | grep -o 'md5=.*'); mb=$(echo "$b" | grep -o 'md5=.*')
  tr=$(grep -h 'R11U181 law' /tmp/v11u181_g/$rel/L.log 2>/dev/null | sed 's/R11U181 law //' | sort | uniq -c | awk '{printf "%s:%s,",$2,$1}')
  mv="SAME"; [ "$ma" != "$mb" ] && mv="MOVED"
  echo "$rel | P: $sa | L: $sb | $mv | $tr | rcP=$(echo "$a"|grep -o 'rc=[0-9]*') rcL=$(echo "$b"|grep -o 'rc=[0-9]*')"
done; done
