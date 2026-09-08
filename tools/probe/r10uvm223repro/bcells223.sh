#!/usr/bin/env bash
# r10uvm223 — THE ORDER-BLIND ARM VERDICT.  MEASUREMENT ONLY.
#
# `bscore223.sh` reads the official judge, which stops at ONE head, so a line
# count can rise merely because the head OBJECT changed.  This one answers the
# boundary's real question — did the arm move TOWARD golden — by comparing the
# WHOLE dumps as line MULTISETS: golden-only lines (MISSING) and ours-only
# lines (EXTRA), for the pristine and the patched database side by side.  Ids
# and absolute paths are normalised away (they are not read by any generated
# Compare and they differ per run); the dumps are SORTED, so nothing here can
# be fooled by ordering (RESUME §9's order-blind rule).
#
# Requires bscore223.sh to have run first (it leaves golden + both databases).
#
#   usage: bcells223.sh <bscore-scratch> [key ...]
set -u
S=${1:?bscore scratch}
shift || true
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
KEYS=${*:-$(cd "$S" && ls -d */ 2>/dev/null | tr -d /)}
norm() { "$DUMP" "$1" 2>/dev/null | sed 's/, id:[0-9]*//g; s#/[^ ,]*/##g' | sort; }
printf "%-44s %-5s %8s %8s   %8s %8s   %s\n" \
       ARM VIEW P_MISS P_EXTRA Q_MISS Q_EXTRA VERDICT
for k in $KEYS; do
  G=$S/$k/g/slpp_all/surelog.uhdm
  [ -f "$G" ] || { printf "%-44s %-5s %8s %8s   %8s %8s   %s\n" "$k" - - - - - "NO GOLDEN"; continue; }
  norm "$G" > "$S/$k/g.norm"
  for ev in def elab; do
    a=$S/$k/a.$ev.uhdm; b=$S/$k/b.$ev.uhdm
    if [ ! -f "$a" ] || [ ! -f "$b" ]; then
      printf "%-44s %-5s %8s %8s   %8s %8s   %s\n" "$k" "$ev" - - - - "NO DATABASE"
      continue
    fi
    norm "$a" > "$S/$k/a.$ev.norm"; norm "$b" > "$S/$k/b.$ev.norm"
    pm=$(comm -23 "$S/$k/g.norm" "$S/$k/a.$ev.norm" | wc -l)
    pe=$(comm -13 "$S/$k/g.norm" "$S/$k/a.$ev.norm" | wc -l)
    qm=$(comm -23 "$S/$k/g.norm" "$S/$k/b.$ev.norm" | wc -l)
    qe=$(comm -13 "$S/$k/g.norm" "$S/$k/b.$ev.norm" | wc -l)
    v=UNCHANGED
    { [ "$qm" -lt "$pm" ] || [ "$qe" -lt "$pe" ]; } && v=TOWARD-GOLDEN
    { [ "$qm" -gt "$pm" ] || [ "$qe" -gt "$pe" ]; } && v=AWAY-GOLDEN
    printf "%-44s %-5s %8s %8s   %8s %8s   %s\n" "$k" "$ev" "$pm" "$pe" "$qm" "$qe" "$v"
  done
done
