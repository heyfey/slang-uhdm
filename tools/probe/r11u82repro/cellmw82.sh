#!/usr/bin/env bash
# Per-CELL moved-wrong: the resolving lister's disagreeing rows, pristine vs <tag>.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CALIST=${CALIST:-$HERE/calist82.py}
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
T=${1:?tag}
tot_new=0; tot_fixed=0
for a in $(ls -d */ | tr -d /); do
  [ -f $a/gold.pris.dump ] && [ -f $a/ours.pris.dump ] && [ -f $a/gold.$T.dump ] && [ -f $a/ours.$T.dump ] || { echo "SKIP $a"; continue; }
  DIFF=1 python3 $CALIST $a/gold.pris.dump $a/ours.pris.dump 2>/dev/null | grep -E "^(!!|\+G|\+O)" | awk '{print $1,$2,$3}' | sort > $TMP/p.txt
  DIFF=1 python3 $CALIST $a/gold.$T.dump $a/ours.$T.dump 2>/dev/null | grep -E "^(!!|\+G|\+O)" | awk '{print $1,$2,$3}' | sort > $TMP/q.txt
  new=$(comm -13 $TMP/p.txt $TMP/q.txt | wc -l)
  fixed=$(comm -23 $TMP/p.txt $TMP/q.txt | wc -l)
  tot_new=$((tot_new+new)); tot_fixed=$((tot_fixed+fixed))
  if [ "$new" != 0 ] || [ "$fixed" != 0 ]; then
    echo "$a  NEW-DISAGREEING=$new  CONVERTED=$fixed"
    comm -13 $TMP/p.txt $TMP/q.txt | sed 's/^/     MOVED-WRONG /'
  fi
done
echo "TOTAL MOVED-WRONG=$tot_new  TOTAL CONVERTED=$tot_fixed  (tag=$T)"
