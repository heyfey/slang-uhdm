#!/usr/bin/env bash
# vdist.sh <tagA> <tagB> [arms...] -- ORDER-BLIND, PATH-NORMALISED uhdm-dump
# distance of each grid arm's database to its OWN golden, for two binaries'
# tags (run.sh writes ours.<tag>.dump / gold.<tag>.dump per arm).
#   TO-GOLDEN  B closer than A      AWAY  B further      NEUTRAL  equal
set -u
A=${1:?tagA}; B=${2:?tagB}; shift 2
ARMS=${*:-$(ls -d /tmp/r11u12_grid/g[0-9]* | xargs -n1 basename | sort -V)}
to=0; away=0; neu=0
T=$(mktemp -d /tmp/r11u12_vdist.XXXXXX); trap 'rm -rf "$T"' EXIT
for a in $ARMS; do
  d=/tmp/r11u12_grid/$a
  [ -f "$d/gold.$A.dump" ] && [ -f "$d/ours.$A.dump" ] && [ -f "$d/ours.$B.dump" ] || { echo "$a MISSING"; continue; }
  norm() { sed -e 's#/tmp/[^ ,)]*##g' -e 's#[0-9a-f]\{8,\}##g' "$1" | sort; }
  norm "$d/gold.$A.dump" > "$T/g"
  norm "$d/ours.$A.dump" > "$T/a"
  norm "$d/ours.$B.dump" > "$T/b"
  da=$(diff "$T/g" "$T/a" | grep -c '^[<>]'; true)
  db=$(diff "$T/g" "$T/b" | grep -c '^[<>]'; true)
  if   [ "$db" -lt "$da" ]; then v=TO-GOLDEN; to=$((to+1))
  elif [ "$db" -gt "$da" ]; then v=AWAY-GOLDEN; away=$((away+1))
  else v=NEUTRAL; neu=$((neu+1)); fi
  echo "$a $A=$da $B=$db $v"
done
echo "TOTALS TO-GOLDEN=$to AWAY-GOLDEN=$away NEUTRAL=$neu"
