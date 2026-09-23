#!/bin/bash
# sw110.sh <grid-out-root>... — switch identities per arm (bytes).
# off must equal pris on EVERY arm; on a mover arm (law != pris) each single
# switch either restores pris (the arm is that law's) or equals law (not its).
# Prints per mover arm the laws that own it, and any arm breaking the rule.
tags="sport sinit sreg sattr smulti"
bad=0; movers=0; arms=0
for R in "$@"; do
  while read -r g <&3; do
    d=$(dirname "$g"); arms=$((arms+1))
    [ -f "$d/law.uhdm" ] || continue
    if ! cmp -s "$d/pris.uhdm" "$d/off.uhdm"; then echo "BAD-OFF $(basename "$R")/${d#$R/}"; bad=$((bad+1)); fi
    cmp -s "$d/pris.uhdm" "$d/law.uhdm" && { for t in $tags; do cmp -s "$d/pris.uhdm" "$d/$t.uhdm" || { echo "BAD-NONMOVER-$t $(basename "$R")/${d#$R/}"; bad=$((bad+1)); }; done; continue; }
    movers=$((movers+1)); own=""
    for t in $tags; do
      if cmp -s "$d/pris.uhdm" "$d/$t.uhdm"; then own="$own $t"
      elif ! cmp -s "$d/law.uhdm" "$d/$t.uhdm"; then own="$own $t(partial)"; fi
    done
    echo "MOVER $(basename "$R")/${d#$R/} owners:${own:- NONE}"
  done 3< <(find "$R" -name gold.uhdm | sort)
done
echo "ARMS=$arms MOVERS=$movers BAD=$bad"
