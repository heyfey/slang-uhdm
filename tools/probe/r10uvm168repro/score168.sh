#!/usr/bin/env bash
# r10uvm168repro/score168.sh — the grid SCORER.  MEASUREMENT ONLY.
#   score168.sh <workdir> [pa|all] [full|ct|rest]
#
# Prints, per design-level section and per view file, one line per cell that is
# not `same`, and a TALLY:
#   TOWARD      pristine != golden, patched == golden
#   AWAY        pristine == golden, patched != golden      <- must be 0
#   MOVED-WRONG pristine != golden, patched != golden, patched != pristine
#   same        patched == pristine
#
# THE THIRD ARGUMENT IS WHY THIS SCRIPT HAS THREE COLUMNS AND NOT ONE.  A law
# that owns ONE compared field must be scored on THAT field, and the fields it
# does NOT own must be shown to be UNMOVED — otherwise a cell whose `vpiSize`
# was already wrong before the pass reads as MOVED-WRONG even though the only
# thing that changed is the field the law owns, moving TOWARD golden.
#   full  the whole payload (ct + size + decompile + value)   — the strictest
#   ct    ONLY `vpiConstType`, the single own field `constant::Compare` reads
#   rest  ONLY `size=` and `dec=` — the fields this law must NOT move, so its
#         TOWARD/AWAY/MOVED-WRONG must ALL be 0 except in the octal arm, whose
#         decompile golden really does re-render (see the law).
# Run all three; report all three.
set -u
W=${1:?workdir}; K=${2:-pa}; PROJ=${3:-full}
tot=0; sm=0; tw=0; aw=0; mw=0; only_g=0; only_o=0
for f in def elab; do
  for side in g a b; do
    [ -f "$W/$K.$side.$f.txt" ] || { echo "FATAL missing $W/$K.$side.$f.txt"; exit 3; }
  done
done
tmp=$(mktemp -d "/tmp/r10uvm168_score.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
proj() {
  case "$PROJ" in
    ct)   sed -E 's/^(ct=[^ ]*).*/\1/' ;;
    rest) sed -E 's/^ct=[^ ]* [^ ]* //' ;;
    *)    cat ;;
  esac
}
for f in def elab; do
  for side in g a b; do
    awk -F'\t' -v v="$f" 'NF>=4{k=v"|"$1"|"$2"|"$3; p=$4; for(i=5;i<=NF;i++)p=p" "$i; print k"\t"p}' \
      "$W/$K.$side.$f.txt" \
      | while IFS=$'\t' read -r k p; do printf '%s\t%s\n' "$k" "$(printf '%s' "$p" | proj)"; done \
      | sort > "$tmp/$side.$f"
  done
done
cat "$tmp"/g.def "$tmp"/g.elab | sort > "$tmp/G"
cat "$tmp"/a.def "$tmp"/a.elab | sort > "$tmp/A"
cat "$tmp"/b.def "$tmp"/b.elab | sort > "$tmp/B"
join -t$'\t' -a1 -a2 -e '<ABSENT>' -o 0,1.2,2.2 -j1 "$tmp/G" "$tmp/A" > "$tmp/GA"
join -t$'\t' -a1 -a2 -e '<ABSENT>' -o 0,1.2,1.3,2.2 -j1 "$tmp/GA" "$tmp/B" > "$tmp/GAB"
while IFS=$'\t' read -r key g a b; do
  tot=$((tot+1))
  if [ "$g" = '<ABSENT>' ]; then only_o=$((only_o+1)); v=ONLY-OURS
  elif [ "$a" = '<ABSENT>' ] && [ "$b" = '<ABSENT>' ]; then only_g=$((only_g+1)); v=ONLY-GOLDEN
  elif [ "$b" = "$a" ]; then sm=$((sm+1)); v=same
  elif [ "$b" = "$g" ]; then tw=$((tw+1)); v=TOWARD
  elif [ "$a" = "$g" ]; then aw=$((aw+1)); v=AWAY
  else mw=$((mw+1)); v=MOVED-WRONG
  fi
  case "$v" in same) ;; *) printf "%-12s %-64s G[%s] A[%s] B[%s]\n" "$v" "$key" "$g" "$a" "$b";; esac
done < "$tmp/GAB"
echo "TALLY[$PROJ] cells=$tot same=$sm TOWARD=$tw AWAY=$aw MOVED-WRONG=$mw ONLY-GOLDEN=$only_g ONLY-OURS=$only_o"
