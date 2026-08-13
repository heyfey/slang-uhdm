#!/usr/bin/env bash
# r10svs13 — THREE-WAY PER-SHAPE MOVER TABLE:  GOLD / PRIS / SHIP.
#
#   usage: ./msthree.sh <golden.uhdm> <pristine slang.uhdm> <patched slang.uhdm>
#
# WHY THIS EXISTS ALONGSIDE msmovers.sh.  msmovers.sh reports ADDED/REMOVED
# between the two OURS dumps, which is the right instrument for a law that mints
# or deletes an object.  THIS law RELOCATES one: the same 481 lines move from
# under the program to uhdm-dump's `weaklyReferenced` tail, so every shape both
# ADDS at its new indent and REMOVES at its old one and the ADDED/REMOVED view
# alone cannot say whether the move CONVERGED.  Only GOLDEN's own count can, so
# it is the third column here.
#
# DEFECT IN THE CARRIED SCRIPT, FOUND AND FIXED HERE:  msmovers.sh builds its key
# with the indentation intact (correct) and then DISPLAYS it through
# `sed -E 's/\t +/\t/'`, which STRIPS the leading spaces from the printed shape.
# Two shapes differing ONLY in depth therefore print as two IDENTICAL-LOOKING
# rows — which is exactly what a relocation produces, and it is unreadable.  This
# script prints the indent explicitly as `(ind N)`.
#
# LAWS ENCODED: `sed 1d` on EVERY dump (uhdm-dump's first line is the database
# path); ADDED and REMOVED never netted; a BARE FIELD line is reported in its own
# section because it absorbs into whichever object owns it.
set -u
G=${1:?golden uhdm}
P=${2:?pristine slang.uhdm}
Q=${3:?patched slang.uhdm}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d)
for pair in "G:$G" "P:$P" "Q:$Q"; do
    k=${pair%%:*}; f=${pair#*:}
    [ -f "$f" ] || { echo "MISSING $f"; exit 6; }
    "$DUMP" "$f" 2>/dev/null | sed '1d' > "$T/$k.dump"
    [ -s "$T/$k.dump" ] || { echo "EMPTY DUMP for $f"; exit 6; }
done
for k in G P Q; do
    sort "$T/$k.dump" | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/$k.cnt"
done
awk -F'\t' -v OFS='\t' '
  FNR==NR && FILENAME ~ /G.cnt$/ { g[$2]=$1; next }
  FNR==NR { }
  FILENAME ~ /P.cnt$/ { p[$2]=$1; next }
  { q[$2]=$1 }
  END {
    for (k in p) if (!(k in q)) q[k]=0
    for (k in q) if (!(k in p)) p[k]=0
    n=0
    for (k in q) {
      if (p[k]==q[k]) continue
      ind = match(k, /[^ ]/) - 1
      obj = (k ~ /\\_/) ? "OBJ" : "FLD"
      printf "%s\t%s\tind %d\tGOLD %d\tPRIS %d\tSHIP %d\t%s\n",
             (q[k]>p[k] ? "ADDED  " : "REMOVED"), obj, ind,
             (k in g ? g[k] : 0), p[k], q[k], substr(k, ind+1)
      n++
    }
    printf "TOTAL SHAPES MOVED\t%d\n", n
  }' "$T/G.cnt" "$T/P.cnt" "$T/Q.cnt" | sort
rm -rf "$T"
