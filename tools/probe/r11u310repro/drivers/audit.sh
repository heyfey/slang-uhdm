# (r11u310: copied from r11u308repro/drivers, renamed to R11U310 / r11u310)
# (r11u308: copied from r11u306repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u304repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u302repro/drivers, renamed to R11U308 / r11u308)
#!/bin/bash
# (r11u308: copied from r11u300repro/drivers, renamed to R11U308 / r11u308)
# r11u286 (copied from r11u284repro; r11u284 copied from r11u282repro) audit.sh  <workdir> <binary>: the binary-path audit of one sweep workdir.  The cmds.txt path list is built
# first and filtered by $FENCED (word boundary) before any file is opened; then each cmds.txt is classified:
# OWN (every `slang:` line names <binary>), OTHER (a `slang:` line names another binary), NOSLANG (no `slang:` line).
source "$(dirname "$0")/env.sh" || exit 3
W=$1; B=$2; [ -d "$W" ] && [ -x "$B" ] || { echo "audit.sh: workdir or binary missing" >&2; exit 2; }
own=0; oth=0; nos=0; fen=0
while read -r p; do
  if echo "$p" | grep -Pq "$FENCERE"; then fen=$((fen+1)); continue; fi
  if grep -q '^slang: ' "$W/$p"; then
    if grep '^slang: ' "$W/$p" | grep -vqF "$B "; then oth=$((oth+1)); echo "OTHER $p"; else own=$((own+1)); fi
  else nos=$((nos+1)); fi
done < <(cd $W && find . -name cmds.txt | sort)
echo "$W own=$own other=$oth noslang=$nos fenced_skipped=$fen"
