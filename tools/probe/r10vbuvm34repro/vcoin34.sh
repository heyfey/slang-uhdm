#!/usr/bin/env bash
# r10vbuvm34repro/vcoin34.sh — NONDETERMINISM CONTROL: compile a directory
# TWICE with the SAME binary and diff order-blind, then compare pristine vs
# patched order-blind.  A directory whose same-binary raw diff is non-empty and
# whose order-blind diffs are all 0 is a COIN, not a mover.  MEASUREMENT ONLY.
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; : "${ROOT:?}"
OUT=${OUT:-/tmp/vbuvm34_coin}; VIEW=${VIEW:-def}
EF=""; [ "$VIEW" = elab ] && EF="--elabuhdm"
rm -rf "$OUT"; mkdir -p "$OUT"
for rel in "$@"; do
  d="$OUT/$(printf '%s' "$rel" | tr '/' '_')"; mkdir -p "$d"
  srcs=(); while IFS= read -r f; do srcs+=("$ROOT/$rel/$f"); done < <(cd "$ROOT/$rel" && ls *.sv *.v 2>/dev/null | LC_ALL=C sort)
  for tag in p1 p2 q1; do
    B=$PRISTINE; [ "$tag" = q1 ] && B=$PATCHED
    ( cd "$d" && "$B" "${srcs[@]}" $EF -o $tag.uhdm >$tag.log 2>&1; echo "rc=$?" >>$tag.log ) </dev/null
    ( cd "$d" && uhdm-dump $tag.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#; s#, id:[0-9]*##g' > $tag.txt ) </dev/null
    ( cd "$d" && LC_ALL=C sort $tag.txt > $tag.sorted ) </dev/null
  done
  rawpp=$(diff "$d/p1.txt" "$d/p2.txt" | grep -c '^[<>]' || true)
  obpp=$(diff "$d/p1.sorted" "$d/p2.sorted" | grep -c '^[<>]' || true)
  rawpq=$(diff "$d/p1.txt" "$d/q1.txt" | grep -c '^[<>]' || true)
  obpq=$(diff "$d/p1.sorted" "$d/q1.sorted" | grep -c '^[<>]' || true)
  obpq2=$(diff "$d/p2.sorted" "$d/q1.sorted" | grep -c '^[<>]' || true)
  echo "$rel  PRISvPRIS raw=$rawpp orderblind=$obpp | PRISvPAT raw=$rawpq orderblind=$obpq (vs run2: $obpq2)"
done
