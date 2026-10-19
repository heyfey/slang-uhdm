#!/bin/bash
# audit.sh <workdir> <expected binary>: fence-filtered cmds.txt audit (path list filtered BEFORE any file is opened)
FENCED="$(grep -m1 '^FENCED=' /tmp/wt_v11u406/tools/probe/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/["'"'"']//g')"
FENCED="$(echo $FENCED | tr " " "|")"; [ "$(echo $FENCED | tr "|" "\n" | wc -l)" = 4 ] || { echo "fence not 4 names"; exit 1; }
W=$1; B=$2
find $W -name cmds.txt | grep -Ev "$FENCED" > /tmp/v11u406_audit.lst
n=$(wc -l < /tmp/v11u406_audit.lst); own=0; other=0; none=0
while read f; do
  if grep -q "$B" "$f"; then own=$((own+1)); elif grep -q 'slang-uhdm\|\.bin ' "$f" && grep -qv surelog "$f"; then other=$((other+1)); echo "OTHER $f"; else none=$((none+1)); fi
done < /tmp/v11u406_audit.lst
echo "cmds.txt (fence-filtered) $n: own=$own other=$other no-slang-line=$none"
