#!/usr/bin/env bash
# r11u17: per-arm ref census, JUDGE-REACHABLE ELAB section only (drops the
# weaklyReferenced tail), golden vs a tagged binary's dump.
# usage: armcen.sh <tag> [arms...]
set -u
TAG=${1:?tag}; shift
GRID=${GRID:-/tmp/r11u17_grid}
CEN=${CEN:-$(dirname "${BASH_SOURCE[0]}")/refcen.py}
ARMS=${*:-$(ls -d $GRID/[cde][0-9]* | xargs -n1 basename | sort -V)}
for a in $ARMS; do
  d=$GRID/$a
  for s in gold.$TAG ours.$TAG; do
    f=$d/$s.dump
    [ -f "$f" ] || continue
    n=$(grep -n '^|uhdmtopModules:' $f | head -1 | cut -d: -f1); n=${n:-1}
    awk -v n=$n 'NR>=n' $f > $d/$s.elab
    w=$(grep -n '^\\_weaklyReferenced:' $d/$s.elab | head -1 | cut -d: -f1)
    if [ -n "$w" ]; then awk -v n=$w 'NR<n' $d/$s.elab > $d/$s.main; else cp $d/$s.elab $d/$s.main; fi
  done
  echo "===== $a"
  python3 $CEN $d/gold.$TAG.main $d/ours.$TAG.main
done
