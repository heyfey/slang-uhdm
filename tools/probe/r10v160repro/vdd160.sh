#!/usr/bin/env bash
# r10v160repro/vdd160.sh — ORDER-BLIND, PATH-NORMALISED whole-dump distance to
# golden, for one cell workdir and one view.  Prints
#   DIST_PRIS  DIST_PAT  ADDED_MATCHING_GOLDEN  DELETED_THAT_GOLDEN_HAS
# where DIST is the number of dump lines that differ between golden and ours
# once both are path-normalised and SORTED (order-blind), and the last column
# is the regression detector: a line our PRISTINE dump had, GOLDEN also has,
# and our PATCHED dump lost.  MEASUREMENT ONLY.
set -u
W=$1; V=$2
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
G="$W/g_$V/slpp_all/surelog.uhdm"; A="$W/a_$V.uhdm"; B="$W/b_$V.uhdm"
[ -f "$G" ] && [ -f "$A" ] && [ -f "$B" ] || { echo "SKIP-NOFILE $W $V"; exit 0; }
T=$(mktemp -d /tmp/v160_dd_XXXXXX)
norm() { sed -e "s#$W/##g" -e "s#$(dirname $W)/##g" -e 's#, id:[0-9]*##g' \
         -e 's#/tmp/[^ ,)]*/##g' "$1" | sort; }
"$D" "$G" > "$T/g.raw" 2>/dev/null; "$D" "$A" > "$T/a.raw" 2>/dev/null; "$D" "$B" > "$T/b.raw" 2>/dev/null
norm "$T/g.raw" > "$T/g"; norm "$T/a.raw" > "$T/a"; norm "$T/b.raw" > "$T/b"
dp=$(comm -3 "$T/g" "$T/a" | wc -l)
db=$(comm -3 "$T/g" "$T/b" | wc -l)
# lines patched ADDED that golden has
add=$(comm -13 "$T/a" "$T/b" | sort > "$T/added"; comm -12 "$T/added" "$T/g" | wc -l)
# lines patched LOST that golden has  <- any nonzero is a regression candidate
del=$(comm -23 "$T/a" "$T/b" | sort > "$T/deleted"; comm -12 "$T/deleted" "$T/g" | wc -l)
echo "$(basename $W) $V DIST_PRIS=$dp DIST_PAT=$db ADD_MATCHING_G=$add DEL_THAT_G_HAS=$del"
[ "$del" != 0 ] && { echo "  --- DELETED LINES GOLDEN HAS ---"; comm -12 "$T/deleted" "$T/g" | head -20; }
rm -rf "$T"
