#!/usr/bin/env bash
# r11v53 cell scorer — r11u53repro/cell53.sh against THIS grid.
#   usage: cells.sh <arm> <tag> <line:col> ...
set -u
R=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
D=$R/grid/${1:?arm}; T=${2:?tag}; shift 2
G=$D/gold.$T.dump; O=$D/ours.$T.dump
[ -f "$G" ] && [ -f "$O" ] || { echo "FATAL: no dumps for $D ($T)"; exit 3; }
printf "%-12s %-6s %s\n" SITE SIDE OBJECT
for site in "$@"; do
  for side in golden ours; do
    f=$G; [ "$side" = ours ] && f=$O
    n=$(grep -c "line:$site," "$f"; true)
    [ "$n" = 0 ] && { printf "%-12s %-6s %s\n" "$site" "$side" MISSING; continue; }
    grep -o "\\\\_[a-z_]*: .*line:$site," "$f" | sed 's/^\\_\([a-z_]*\):.*/\1/' \
      | sort | uniq -c | while read -r c k; do printf "%-12s %-6s %s x%s\n" "$site" "$side" "$k" "$c"; done
  done
done
