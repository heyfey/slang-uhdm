#!/usr/bin/env bash
# r10uvm180 WIDE boundary gate (REUSED VERBATIM from r10uvm178repro/bound178.sh, itself r10buvm30 bound30.sh) — EVERY .sv/.v under a COPY of tools/probe,
# both binaries, DEF and ELAB.  fd-3 list, children </dev/null, PROCESSED
# asserted, recursive (subdir arms), fenced names skipped and COUNTED.
set -u
PRI=${PRI:?}; PAT=${PAT:?}
ROOT=${ROOT:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
WD=${BWD:-/tmp/r10uvm180_bound}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/sources.txt
# NO PATH FILTER and BOTH source suffixes: an arm that lives outside a
# `*repro*` directory, or is written as `.v`, is still an arm this law could
# move.  (uvm95's bound95.sh filtered on `*repro*` and `.sv` only.)
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) | sort > "$LIST"
listed=$(wc -l < "$LIST")
[ "$listed" -gt 0 ] || { echo "EMPTY-LIST"; exit 4; }
n=0; moved=0; noout=0; fenced=0; proc=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
  n=$((n+1))
  # The four slang-fenced test names are NEVER dispatched and are NEVER
  # SPELLED in a probe artifact.  Supply them from outside as an extended
  # regex, e.g.  FENCE_RE="$(cat ~/.config/slang-uhdm/fenced.re)".  Empty
  # (the default) is correct here: no arm file under tools/probe is named
  # after any of them, which this gate asserts by reporting FENCED_SKIPPED.
  if [ -n "${FENCE_RE:-}" ] && printf '%s' "$(basename "$src")" | grep -qE "$FENCE_RE"; then
    fenced=$((fenced+1)); continue
  fi
  rel=${src#$ROOT/}
  b=$(printf "%04d_%s" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
  o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/" || continue
  leaf=$(basename "$src")
  proc=$((proc+1))
  for m in def elab; do
    fl=""; [ $m = elab ] && fl="-elabuhdm"
    ( cd "$o" && "$PRI" $fl "$leaf" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null )
    ( cd "$o" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null )
    if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
      if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then
        echo "ASYMMETRIC_OUTPUT $b/$m"; moved=$((moved+1))
      else
        noout=$((noout+1))
      fi
      continue
    fi
    "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
    "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
    if ! cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump"; then
      echo "MOVED $b/$m $(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true) lines"
      moved=$((moved+1))
    fi
  done
done
exec 3<&-
echo "LISTED=$listed FENCED_SKIPPED=$fenced PROCESSED=$proc MOVED=$moved NO_OUTPUT_PAIRS=$noout"
[ $((proc+fenced)) -eq "$listed" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
