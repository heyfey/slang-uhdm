#!/usr/bin/env bash
# r10uvm162repro/dist162.sh — the ORDER-BLIND whole-dump distance to golden,
# for the pristine and the patched database of one grid arm workdir, in both
# views.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
#   usage: dist162.sh <arm workdir> [<arm workdir> ...]
#
# Dump paths embed the workdir and the serializer ids differ run to run
# (RESUME.md §9), so both are normalised away before the sets are compared.
# Scoreboard-style nondeterminism is why this is ORDER-BLIND: the dumps are
# SORTED and the distance is the size of the symmetric difference.  A distance
# that FALLS is TOWARD golden; ADDED / DELETED say which way the lines moved.
set -u
norm() { sed -e 's#/tmp/[^ ,)]*##g' -e 's#, id:[0-9]*##g' "$1" | sort; }
printf "%-22s %-4s %-8s %8s %8s %8s %s\n" ARM VIEW SIDE ADDED DELETED DIST VERDICT
for W in "$@"; do
  N=$(basename "$W")
  for v in def elab; do
    G="$W/g.$v.dump"
    [ -s "$G" ] || { printf "%-22s %-4s %-8s %s\n" "$N" "$v" - "SKIP-NOGOLDEN"; continue; }
    norm "$G" > "$W/.g.$v.n"
    pd=""
    for side in a b; do
      D="$W/$side.$v.dump"
      [ -s "$D" ] || { printf "%-22s %-4s %-8s %s\n" "$N" "$v" "$side" "SKIP-NODUMP"; continue; }
      norm "$D" > "$W/.$side.$v.n"
      add=$(comm -13 "$W/.g.$v.n" "$W/.$side.$v.n" | wc -l)
      del=$(comm -23 "$W/.g.$v.n" "$W/.$side.$v.n" | wc -l)
      dist=$((add + del))
      lbl=$([ "$side" = a ] && echo PRISTINE || echo PATCHED)
      verdict=""
      if [ "$side" = b ] && [ -n "$pd" ]; then
        if [ "$dist" -lt "$pd" ]; then verdict="TOWARD ($pd -> $dist)"
        elif [ "$dist" -gt "$pd" ]; then verdict="AWAY ($pd -> $dist)"
        else verdict="SAME"; fi
      fi
      [ "$side" = a ] && pd=$dist
      printf "%-22s %-4s %-8s %8s %8s %8s %s\n" "$N" "$v" "$lbl" "$add" "$del" "$dist" "$verdict"
    done
  done
done
