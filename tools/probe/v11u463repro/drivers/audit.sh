#!/bin/bash
# audit.sh <workdir> <binary>: per stage, cmds.txt records (fence-filtered paths) naming the binary
W=$1; B=$2
for st in surelog uhdm2rtlil svtests; do
  find $W/$st -name cmds.txt | grep -v -F -f /tmp/v11u463_fenced.txt > /tmp/v11u463_scr/cmds_$st.lst
  tot=0; hit=0; oth=0; none=0
  while read f; do tot=$((tot+1)); l=$(grep -E '^slang' "$f" | awk '{print $2}' | sort -u)
    if [ -z "$l" ]; then none=$((none+1)); elif [ "$l" = "$B" ]; then hit=$((hit+1)); else oth=$((oth+1)); fi
  done < /tmp/v11u463_scr/cmds_$st.lst
  echo "$st: $hit of $tot records name $B; no slang line $none; another binary $oth"
done
