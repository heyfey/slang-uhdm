#!/usr/bin/env bash
# r10uvm153 — the twelve protected databases by NAME (md5 patched vs pristine),
# plus the two pinned prefixes the brief names.
set -u
PRIS=${1:?}; PAT=${2:?}
for n in InterfaceModPort BlackParrotComplex YosysOldOr SVSwitch YosysVerx; do
  for m in default testflags; do
    for d in "$PRIS/$m/$n"-*/; do
      [ -f "$d/slang.uhdm" ] || continue
      rel=${d#$PRIS/}
      q="$PAT/$rel/slang.uhdm"
      [ -f "$q" ] || { echo "MISSING $rel"; continue; }
      a=$(md5sum < "$d/slang.uhdm" | cut -c1-12); b=$(md5sum < "$q" | cut -c1-12)
      [ "$a" = "$b" ] && echo "SAME    $m/$n  $b" || echo "CHANGED $m/$n  $a -> $b"
    done
  done
done
