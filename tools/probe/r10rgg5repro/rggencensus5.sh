#!/usr/bin/env bash
# r10rgg5/rggencensus5.sh -- the GOLDEN-vs-OURS census of the Rggen head family:
# every `get_next_n` ARGUMENT constant of the design, keyed by the instance path
# the object's ref_typespec names, so DEFICIT (golden rows we do not reproduce)
# is countable BY NAME.
#
#   usage: rggencensus5.sh <golden.dump> <base.dump> <pat.dump>
#
# GUARD: a side yielding NO row prints NONE and is counted; a golden key absent
# from a side prints MISSING and is counted (never silently dropped).
set -u
G=${1:?golden dump}; B=${2:?base dump}; P=${3:?pat dump}
here=$(cd "$(dirname "$0")" && pwd)
bad=0
for tag in GOLD BASE PAT; do
  case $tag in GOLD) f=$G;; BASE) f=$B;; PAT) f=$P;; esac
  python3 "$here/argconst.py" "$f" "$tag" 2>/dev/null |
    sed -n '/^-- per-instance/,$p' | tail -n +2 |
    awk '{print $5"|"$1"|"$3"|"$4}' | grep -v '^-|' | sort > /tmp/r10rgg5_cs_$tag.txt
  n=$(wc -l < /tmp/r10rgg5_cs_$tag.txt)
  [ "$n" -eq 0 ] && { echo "$tag NONE"; bad=$((bad+1)); }
  echo "-- $tag rows=$n"
done
echo "==== the 13 GOLDEN instances, golden vs base vs pat"
printf "%-70s %-22s %-22s %s\n" KEY GOLD BASE PAT
def=0; fixed=0; still=0
while IFS='|' read -r path site size dec; do
  k="$path|$site"
  gb="$size/$dec"
  bb=$(awk -F'|' -v k="$path|$site" '$1"|"$2==k{print $3"/"$4}' /tmp/r10rgg5_cs_BASE.txt)
  pb=$(awk -F'|' -v k="$path|$site" '$1"|"$2==k{print $3"/"$4}' /tmp/r10rgg5_cs_PAT.txt)
  [ -z "$bb" ] && { bb=MISSING; bad=$((bad+1)); }
  [ -z "$pb" ] && { pb=MISSING; bad=$((bad+1)); }
  printf "%-70s %-22s %-22s %s\n" "$(echo "$path" | sed 's/^work@rggen\.//' | cut -c1-68).$site" \
      "$gb" "$bb" "$pb"
  [ "$bb" != "$gb" ] && def=$((def+1))
  [ "$bb" != "$gb" ] && [ "$pb" = "$gb" ] && fixed=$((fixed+1))
  [ "$pb" != "$gb" ] && still=$((still+1))
done < /tmp/r10rgg5_cs_GOLD.txt
echo "GOLDEN ROWS=$(wc -l < /tmp/r10rgg5_cs_GOLD.txt)  BASE-DEFICIT=$def  FIXED=$fixed  STILL-DIFFERING=$still  PROBLEMS=$bad"
