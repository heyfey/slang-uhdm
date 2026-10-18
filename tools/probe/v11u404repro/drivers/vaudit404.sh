#!/bin/bash
# vaudit404.sh <workdir> <expected binary> : every cmds.txt (path list fence-filtered BEFORE any file is
# opened) whose slang line names a binary must name only <expected binary>.
W=$1; B=$2
eval "$(grep '^FENCED=' /tmp/wt_v11u404/tools/probe/r11u107repro/canaudit.sh)"
pat=$(echo $FENCED | sed 's/ /|/g')
find $W -name cmds.txt | grep -vE "$pat" > /tmp/v11u404_audit_list.$$
tot=$(wc -l < /tmp/v11u404_audit_list.$$); own=0; other=0; none=0
while read f; do
  if grep -q "$B" "$f"; then
    if grep -E '/slang-uhdm |/build/slang-uhdm|/v11u404_bin/(pris|law|ver)' "$f" | grep -vq "$B"; then other=$((other+1)); else own=$((own+1)); fi
  else none=$((none+1)); fi
done < /tmp/v11u404_audit_list.$$
rm -f /tmp/v11u404_audit_list.$$
echo "$W: cmds.txt (fence-filtered) $tot, naming $B only $own, naming another binary $other, naming none $none"
