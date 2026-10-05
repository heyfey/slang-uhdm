#!/bin/bash
# (r11u245) cmdsaudit.sh <sweep workdir> <expected binary>: the binary-path audit of a gate sweep.  The path list of
# every cmds.txt is built FIRST and filtered by $FENCED (word boundary, fail-closed) before any file is opened; then
# each kept cmds.txt is read for the slang-uhdm binary PATH it ran.  Prints the per-binary counts.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "cmdsaudit.sh: source drivers/env.sh (FENCED)" >&2; exit 2; }
W=$1; X=$2; fre=$(echo $FENCED | sed 's/ /|/g')
L=$(mktemp); find $W/surelog $W/uhdm2rtlil -name cmds.txt | grep -vwE "$fre" | sort > $L
echo "listed=$(find $W/surelog $W/uhdm2rtlil -name cmds.txt | wc -l) kept=$(wc -l < $L)"
xargs -a $L grep -h '^slang:' 2>/dev/null | awk '{print $2}' | sort | uniq -c
echo "expected=$X"; rm -f $L
