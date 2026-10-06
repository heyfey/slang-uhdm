#!/bin/bash
# (v11u263) binaudit.sh <sweep workdir> <expected binary>: over the fence-filtered list of cmds.txt (path list built and
# filtered by $FENCED BEFORE any file is opened), count the files naming the expected binary, naming another
# /tmp/v11u263_bin binary, or carrying no slang line.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "binaudit.sh: FENCED unset" >&2; exit 2; }
W=$1; X=$2; fre=$(echo $FENCED | sed 's/ /|/g')
cd $W && find . -name cmds.txt | sort | grep -vwE "$fre" > /tmp/v11u263_ba_list.$$
tot=$(wc -l < /tmp/v11u263_ba_list.$$); own=0; other=0; none=0
while read -r f; do
  if grep -q "^slang:" "$f"; then
    if grep "^slang:" "$f" | grep -q "$X "; then own=$((own+1)); else other=$((other+1)); fi
  else none=$((none+1)); fi
done < /tmp/v11u263_ba_list.$$
rm -f /tmp/v11u263_ba_list.$$
echo "$W: cmds.txt=$tot own=$own other=$other no_slang_line=$none"
