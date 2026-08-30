#!/usr/bin/env bash
# r10v162 — THE STRICT AWAY TEST at dump-line level, per arm and view.
#   LOST   = normalised lines that GOLDEN has and PRISTINE matched but PATCHED
#            no longer matches  (a line that was right and became wrong)
#   GAINED = normalised lines that GOLDEN has and PATCHED matched but PRISTINE
#            did not                    (a line that was wrong and became right)
#   NEWONLYOURS = lines only PATCHED has that golden does not, and pristine did
#            not have either            (a freshly minted line golden lacks)
# Multiset-safe: `comm` on sorted line sets is set-based, so counts here are
# distinct-line counts.  MEASUREMENT ONLY.
set -u
norm() { sed -e 's#/tmp/[^ ,)]*##g' -e 's#, id:[0-9]*##g' "$1" | sort -u; }
printf "%-22s %-4s %8s %8s %13s\n" ARM VIEW LOST GAINED NEWONLYOURS
for W in "$@"; do
  N=$(basename "$W")
  for v in def elab; do
    [ -s "$W/g.$v.dump" ] && [ -s "$W/a.$v.dump" ] && [ -s "$W/b.$v.dump" ] || {
      printf "%-22s %-4s %s\n" "$N" "$v" SKIP; continue; }
    norm "$W/g.$v.dump" > "$W/.G"; norm "$W/a.$v.dump" > "$W/.A"; norm "$W/b.$v.dump" > "$W/.B"
    comm -12 "$W/.G" "$W/.A" > "$W/.GA"
    comm -12 "$W/.G" "$W/.B" > "$W/.GB"
    lost=$(comm -23 "$W/.GA" "$W/.GB" | wc -l)
    gained=$(comm -13 "$W/.GA" "$W/.GB" | wc -l)
    comm -23 "$W/.B" "$W/.G" > "$W/.BonlyG"
    newonly=$(comm -23 "$W/.BonlyG" "$W/.A" | wc -l)
    printf "%-22s %-4s %8s %8s %13s\n" "$N" "$v" "$lost" "$gained" "$newonly"
  done
done
