#!/usr/bin/env bash
# r10uvm73 — PER-CELL table for an arm workdir: for each NAMED variable, print
# golden's (LHS) and our (RHS) object KIND and the ACTUAL typespec the var's
# ref_typespec points at (or NONE).  LHS is ALWAYS golden.
#
#   usage: ct73cells.sh <armwd> <cellname> [<cellname> ...]
#
# GUARDS: a cell name that appears in NEITHER dump prints UNKNOWN-CELL and is
# counted — a driver that matches nothing must never read as agreement.  The
# kind set is MERGED over every print of the object (the dump prints one object
# once per print-chain that reaches it) and a within-side disagreement is shown
# as `a|b`, never collapsed.
set -u
D=${1:?arm workdir}
shift
[ -s "$D/g.dump" ] && [ -s "$D/o.dump" ] || { echo "FATAL: no dumps in $D"; exit 3; }
printf '%-22s %-26s %-26s %s\n' CELL 'LHS golden (kind / actual)' 'RHS ours (kind / actual)' VERDICT
unk=0; agree=0; dis=0
for c in "$@"; do
  seen=0
  for side in g o; do
    f=$D/$side.dump
    k=$(grep -oE '\\_[a-z_0-9]+: \([^)]*::'"$c"'\)' "$f" | sed 's/.*\\_//; s/:.*//' | sort -u | paste -sd'|')
    [ -n "$k" ] || k=$(grep -oE '\\_[a-z_0-9]+: \('"$c"'\)' "$f" | sed 's/.*\\_//; s/:.*//' | sort -u | paste -sd'|')
    # the actual typespec: first ref_typespec block naming the cell, then its vpiActual
    a=$(awk -v c="$c" '
        $0 ~ ("\\\\_ref_typespec: \\(([A-Za-z_0-9:]*::)?" c "\\)") {want=1; next}
        want && /vpiActual:/ {getline; sub(/^ *\\_/,""); sub(/, line.*/,""); print; exit}
      ' "$f")
    [ -n "$a" ] || a=NONE
    [ -n "$k" ] && seen=1
    if [ "$side" = g ]; then gk=$k; ga=$a; else ok=$k; oa=$a; fi
  done
  if [ "$seen" -eq 0 ]; then
    printf '%-22s %-26s %-26s %s\n' "$c" - - UNKNOWN-CELL; unk=$((unk+1)); continue
  fi
  v=AGREE; [ "$gk/$ga" = "$ok/$oa" ] || v=DISAGREE
  [ "$v" = AGREE ] && agree=$((agree+1)) || dis=$((dis+1))
  printf '%-22s %-26s %-26s %s\n' "$c" "${gk:--} / $ga" "${ok:--} / $oa" "$v"
done
echo "-- cells: agree=$agree DISAGREE=$dis UNKNOWN-CELL=$unk"
