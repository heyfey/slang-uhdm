#!/usr/bin/env bash
# r11v53 DIRECTION SCORER — per arm, the ORDER-BLIND whole-dump residue against
# GOLDEN under each named binary tag.  DOWN is toward golden, UP is away, and an
# arm whose residue does not move is an arm the law did not touch.
#   usage: [TAGS="base impl fix"] toward.sh [arm ...]
set -u
R=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
TAGS=${TAGS:-base impl fix}
ARMS=${*:-$(ls -d $R/grid/*/ | xargs -n1 basename | sort -V)}
printf "%-24s" ARM; for t in $TAGS; do printf " %12s" "$t(g+o)"; done; printf "  %s\n" "impl-vs-base fix-vs-base"
for a in $ARMS; do
  d=$R/grid/$a; g=$d/slpp_all/surelog.uhdm
  [ -f "$g" ] || { echo "$a NO-GOLDEN"; continue; }
  $DUMP "$g" 2>/dev/null | sed -e "s#$d/##g" | sort > /tmp/.tw53v.g.$$
  tot=""
  for t in $TAGS; do
    o=$d/ours.$t.uhdm
    if [ ! -f "$o" ]; then tot="$tot -"; continue; fi
    $DUMP "$o" 2>/dev/null | sed -e "s#$d/##g" | sort > /tmp/.tw53v.o.$$
    diff /tmp/.tw53v.g.$$ /tmp/.tw53v.o.$$ > /tmp/.tw53v.d.$$; true
    tot="$tot $(grep -c '^[<>]' /tmp/.tw53v.d.$$; true)"
  done
  set -- $tot
  b=${1:-0}; i=${2:-0}; f=${3:-0}
  dir() { [ "$1" -lt "$b" ] && echo "TOWARD(-$((b-$1)))" || { [ "$1" -gt "$b" ] && echo "AWAY(+$(($1-b)))" || echo UNCHANGED; }; }
  printf "%-24s" "$a"; for v in $tot; do printf " %12s" "$v"; done
  printf "  %-14s %s\n" "$(dir $i)" "$(dir $f)"
done
rm -f /tmp/.tw53v.g.$$ /tmp/.tw53v.o.$$ /tmp/.tw53v.d.$$
