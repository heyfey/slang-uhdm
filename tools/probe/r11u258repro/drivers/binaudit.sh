#!/bin/bash
# r11u258 binaudit.sh <sweep workdir> <expected binary>: the binary-path audit of a gate sweep. Every cmds.txt of the
# surelog and uhdm2rtlil stages is listed first, the list filtered by $FENCED (word boundary) BEFORE any file is
# opened; then each is classified: names the expected binary / names another slang-uhdm binary / no slang line.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "binaudit.sh: source drivers/env.sh (FENCED)" >&2; exit 2; }
W=$1; X=$2; fre=$(echo $FENCED | tr ' ' '|')
tot=0; ok=0; other=0; none=0; sk=0
while read -r f; do
  if echo "$f" | grep -qwE "$fre"; then sk=$((sk+1)); continue; fi
  tot=$((tot+1))
  l=$(grep -m1 '^slang:' "$W/$f")
  if [ -z "$l" ]; then none=$((none+1))
  elif echo "$l" | grep -qF "$X "; then ok=$((ok+1))
  else other=$((other+1)); echo "OTHER $f"; fi
done < <(cd $W && find surelog uhdm2rtlil -name cmds.txt | sort)
echo "cmds.txt=$tot expected-binary=$ok other-binary=$other no-slang-line=$none fenced-skipped-unread=$sk"
