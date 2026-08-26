#!/usr/bin/env bash
# r10v160repro/vrowdd160.sh — ORDER-BLIND, PATH-NORMALISED distance to golden
# for ONE sweep row, pristine and patched.  The golden is read out of the row's
# OWN cmds.txt so the wrong golden cannot be compared by accident.  The last
# column is the regression detector: a dump line GOLDEN has that our PRISTINE
# database had and our PATCHED one LOST.  MEASUREMENT ONLY; LHS is golden.
#   vrowdd160.sh <pris workdir> <pat workdir> <rel>
set -u
A=$1; B=$2; rel=$3
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
[ -f "$A/$rel/slang.uhdm" ] && [ -f "$B/$rel/slang.uhdm" ] || { echo "$rel SKIP-NOFILE"; exit 0; }
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$A/$rel/cmds.txt" | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
[ -f "$G" ] || { echo "$rel SKIP-NOGOLDEN"; exit 0; }
T=$(mktemp -d /tmp/v160_rdd_XXXXXX)
"$D" "$G" 2>/dev/null | sed -e 's#, id:[0-9]*##g' -e 's#file:[^,]*,##g' | sort > "$T/g"
"$D" "$A/$rel/slang.uhdm" 2>/dev/null | sed -e 's#, id:[0-9]*##g' -e 's#file:[^,]*,##g' -e "s#$A/##g" | sort > "$T/a"
"$D" "$B/$rel/slang.uhdm" 2>/dev/null | sed -e 's#, id:[0-9]*##g' -e 's#file:[^,]*,##g' -e "s#$B/##g" | sort > "$T/b"
dp=$(comm -3 "$T/g" "$T/a" | wc -l); db=$(comm -3 "$T/g" "$T/b" | wc -l)
comm -13 "$T/a" "$T/b" | sort > "$T/added"; comm -23 "$T/a" "$T/b" | sort > "$T/deleted"
add=$(comm -12 "$T/added" "$T/g" | wc -l); del=$(comm -12 "$T/deleted" "$T/g" | wc -l)
na=$(wc -l < "$T/added"); nd=$(wc -l < "$T/deleted")
echo "$rel DIST_PRIS=$dp DIST_PAT=$db ADDED=$na ADD_MATCHING_G=$add DELETED=$nd DEL_THAT_G_HAS=$del"
[ "$del" != 0 ] && { echo "  --- LINES GOLDEN HAS THAT PATCHED LOST ---"; comm -12 "$T/deleted" "$T/g" | head -25; }
rm -rf "$T"
