#!/usr/bin/env bash
# r11u51 CELL SCORER.  For one grid arm, print — per VIEW (DEF = the
# uhdmall* listing, ELAB = the uhdmtop* listing, TAIL = weaklyReferenced) —
# the object kind that sits at each named SOURCE SITE, on BOTH sides.
#
#   usage: cell51.sh <arm> <tag> <line:col> [<line:col> ...]
#
# WHY IT IS SITE-KEYED AND VIEW-SECTIONED: the producer compiles a module
# TWICE (definition, then per instance) and a package TWICE (Reduce::Yes then
# Reduce::No), so "golden folds" is never a whole-design fact — it is a fact
# about one copy.  Keying on the SOURCE location is what lines the copies of
# the two producers up; keying on ids would not.
# GUARD: a site with ZERO hits on a side prints MISSING and is counted, so an
# arm that reaches nothing can never read as agreement.
set -u
D=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/grid/${1:?arm}
T=${2:?tag}
shift 2
G=$D/gold.$T.dump; O=$D/ours.$T.dump
[ -f "$G" ] && [ -f "$O" ] || { echo "FATAL: no dumps for $D ($T)"; exit 3; }
sect() {   # $1 dump, $2 line-number -> DEF/ELAB/TAIL
  awk -v n="$2" '/uhdmall(Modules|Packages|Classes):/{if(NR<n) s="DEF"}
                 /uhdmtop(Modules|Packages):/{if(NR<n) s="ELAB"}
                 /weaklyReferenced:/{if(NR<n) s="TAIL"}
                 END{print (s==""?"HEAD":s)}' "$1"
}
printf "%-12s %-5s %-6s %s\n" SITE SIDE VIEW OBJECT
miss=0
for site in "$@"; do
  for side in golden ours; do
    f=$G; [ "$side" = ours ] && f=$O
    n=$(grep -c "line:$site," "$f"; true)
    if [ "$n" = 0 ]; then
      printf "%-12s %-5s %-6s %s\n" "$site" "$side" - MISSING; miss=$((miss+1)); continue
    fi
    grep -n "line:$site," "$f" | while IFS=: read -r ln rest; do
      kind=$(echo "$rest" | sed -n 's/.*\\_\([a-z_]*\):.*/\1/p')
      [ -z "$kind" ] && kind=$(echo "$rest" | sed 's/^ *//;s/ .*//')
      v=$(sect "$f" "$ln")
      printf "%-12s %-5s %-6s %s\n" "$site" "$side" "$v" "$kind"
    done
  done
done
echo "-- MISSING cells: $miss"
