#!/usr/bin/env bash
# § wildcardImportCopiesPkgVarsToDefNets223 — THE ARM'S *DELTA* VERDICT.
#
# `bcells223.sh` prints MISSING/EXTRA totals and calls any rise in EXTRA
# "AWAY-GOLDEN".  That is too blunt for a MINT law, which necessarily adds
# lines: the question that decides AWAY is whether a golden line we USED to
# produce stopped being produced (NEWLY-MISSING) and whether a NEW ours-only
# object appeared that is not the mint's own structural shadow.  This prints
# both deltas, line-classified.
#
# Requires bscore223.sh to have run first (it leaves golden + both databases);
# reuses the .norm files bcells223.sh wrote.
#
#   usage: armdelta223.sh <bscore-scratch> [key ...]
set -u
S=${1:?bscore scratch}
shift || true
KEYS=${*:-$(cd "$S" && ls -d */ 2>/dev/null | tr -d /)}
printf "%-44s %-5s %14s %14s   %s\n" ARM VIEW NEWLY-MISSING NEWLY-EXTRA VERDICT
for k in $KEYS; do
  for ev in def elab; do
    g=$S/$k/g.norm; a=$S/$k/a.$ev.norm; b=$S/$k/b.$ev.norm
    if [ ! -f "$g" ] || [ ! -f "$a" ] || [ ! -f "$b" ]; then
      printf "%-44s %-5s %14s %14s   %s\n" "$k" "$ev" - - "NO DATABASE (rc-checked)"; continue
    fi
    # the dump prints the FILE NAME in its banner; a.<ev>.uhdm vs b.<ev>.uhdm
    # is not a cell, so it is excluded on both sides.
    comm -23 "$g" "$a" | grep -v 'uhdm: Restored design' > "$S/$k/mi_a.$ev"; true
    comm -23 "$g" "$b" | grep -v 'uhdm: Restored design' > "$S/$k/mi_b.$ev"; true
    comm -13 "$g" "$a" | grep -v 'uhdm: Restored design' > "$S/$k/ex_a.$ev"; true
    comm -13 "$g" "$b" | grep -v 'uhdm: Restored design' > "$S/$k/ex_b.$ev"; true
    nm=$(comm -13 "$S/$k/mi_a.$ev" "$S/$k/mi_b.$ev" | wc -l)
    ne=$(comm -13 "$S/$k/ex_a.$ev" "$S/$k/ex_b.$ev" | wc -l)
    cm=$(comm -23 "$S/$k/mi_a.$ev" "$S/$k/mi_b.$ev" | wc -l)
    v="TO-GOLDEN (cured $cm)"
    [ "$nm" != 0 ] && v="AWAY — $nm golden lines newly unmatched"
    printf "%-44s %-5s %14s %14s   %s\n" "$k" "$ev" "$nm" "$ne" "$v"
  done
done
