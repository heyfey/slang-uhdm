#!/bin/bash
# v11u245: cmdsaudit.sh <sweep wd> <binary>: every cmds.txt of a gate sweep (path list filtered by $FENCED before any
# file is opened) must name the given frozen binary and no other slang-uhdm binary.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "cmdsaudit.sh: source drivers/env.sh" >&2; exit 2; }
W=$1; BIN=$2; fre=$(echo $FENCED | sed 's/ /|/g')
L=$(mktemp); (cd $W && find . -name cmds.txt | sort | grep -vwE "$fre") > $L
n=$(wc -l < $L); ok=0; bad=0
while read -r p; do sl=$(grep '^slang:' "$W/$p" | awk '{print $2}' | sort -u); if [ "$sl" = "$BIN" ]; then ok=$((ok+1)); else bad=$((bad+1)); echo "BAD $p"; fi; done < $L
rm -f $L; echo "cmds.txt kept=$n naming $BIN only=$ok other=$bad"
