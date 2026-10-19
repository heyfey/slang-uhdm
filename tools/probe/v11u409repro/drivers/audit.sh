#!/bin/bash
# $1 workdir, $2 binary path
W=$1; B=$2
find $W/surelog $W/uhdm2rtlil $W/downstream -name cmds.txt > /tmp/v11u409_cmds_all.txt
grep -v -F -f /tmp/v11u409_fence.txt /tmp/v11u409_cmds_all.txt > /tmp/v11u409_cmds.txt
own=0; other=0; none=0
while read f; do if grep -q "$B" $f; then own=$((own+1)); elif grep -q 'slang' $f; then other=$((other+1)); else none=$((none+1)); fi; done < /tmp/v11u409_cmds.txt
echo "cmds all=$(wc -l < /tmp/v11u409_cmds_all.txt) fence-filtered=$(wc -l < /tmp/v11u409_cmds.txt) own=$own other=$other noslang=$none"
