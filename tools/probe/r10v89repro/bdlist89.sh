#!/usr/bin/env bash
# r10earl89 — build the WIDE BOUNDARY file list from a COPY of tools/probe.
# The four slang-fenced test names are read OUT OF `canaudit.sh` (the only file
# in this directory that may spell them) and filtered out, so no fenced test is
# ever dispatched and no probe artifact here spells one.
#   usage: bdlist89.sh <probe-root-copy> <out-list>
set -u
ROOT=$(readlink -f "$1"); OUT="$2"
FENCE=$(grep -m1 "^FENCED=" canaudit.sh | sed "s/^FENCED=//; s/\"//g" | tr " " "\n" | grep . | tr "\n" "|" | sed "s/|$//")
[ -n "$FENCE" ] || { echo "FENCE LIST EMPTY — refusing" >&2; exit 2; }
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | sort > "$OUT.all"
grep -Ev "$FENCE" "$OUT.all" > "$OUT"
echo "LISTED=$(grep -c '^' "$OUT"; true) FENCED=$(( $(grep -c '^' "$OUT.all") - $(grep -c '^' "$OUT") ))"
