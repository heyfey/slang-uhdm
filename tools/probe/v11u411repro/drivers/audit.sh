#!/bin/bash
# audit.sh <workdir> <binary path> <stage...>: fence-filtered cmds.txt naming the binary under test
W=$1; B=$2; shift 2
for st in "$@"; do
 find $W/$st -name cmds.txt > /tmp/v11u411_cmds_all.txt
 grep -v -F -f /tmp/v11u411_fence.txt /tmp/v11u411_cmds_all.txt > /tmp/v11u411_cmds.txt
 own=0; other=0; none=0
 while read f; do if grep -q "$B" $f; then own=$((own+1)); elif grep -q 'slang' $f; then other=$((other+1)); else none=$((none+1)); fi; done < /tmp/v11u411_cmds.txt
 echo "$st cmds all=$(wc -l < /tmp/v11u411_cmds_all.txt) fence-filtered=$(wc -l < /tmp/v11u411_cmds.txt) own=$own other=$other noslang=$none"
done
