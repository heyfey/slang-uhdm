#!/usr/bin/env bash
# r10vbuvm16 (VERIFIER) — WHOLE-DUMP path-normalised diff, pristine vs patched,
# for one .sv arm.  Sees everything the census cannot: spans, names, parents,
# any node kind.  usage: PRISTINE= PATCHED= vdump16.sh <file.sv>
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
SRC=${1:?file.sv}; B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/vbuvm16_dd_XXXXXX); cp "$SRC" "$W/$B.sv"; cd "$W" || exit 3
"$PRISTINE" "$B.sv" -o p.uhdm >p.log 2>&1
"$PATCHED"  "$B.sv" -o q.uhdm >q.log 2>&1
[ -s p.uhdm ] && [ -s q.uhdm ] || { echo "REJECT $B (wd=$W)"; exit 5; }
norm() { uhdm-dump "$1" | sed -e "s#$W#<WD>#g" -e 's#id:[0-9]*#id:N#g'; }
norm p.uhdm > p.txt; norm q.uhdm > q.txt
echo "== dumpdiff $B  wd=$W  lines p=$(wc -l < p.txt) q=$(wc -l < q.txt)"
if cmp -s p.txt q.txt; then echo "IDENTICAL"; else
  echo "SIDES=$(diff p.txt q.txt | grep -cE '^[<>]')"
  diff p.txt q.txt | grep -E '^[<>]' | sed -E 's/[0-9]+//g' | sort | uniq -c | sort -rn | head -20
  echo "-- raw first 30:"; diff p.txt q.txt | grep -E '^[<>]' | head -30
fi
