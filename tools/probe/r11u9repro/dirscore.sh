#!/usr/bin/env bash
# dirscore.sh <pristine-workdir> <patched-workdir> <mode> <names...>
# DIRECTIONAL census: for each named row, the ORDER-BLIND, PATH-NORMALISED
# uhdm-dump distance to that row's OWN golden, on both binaries.
#   TO-GOLDEN  patched distance < pristine distance
#   AWAY       patched > pristine      NEUTRAL  equal
# Paths embed the workdir, so both sides are normalised before the diff, and the
# diff is order-blind (sort) because dump ORDER is not what the judge reads.
set -u
P=$1; Q=$2; M=$3; shift 3
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d /tmp/r11u9_dirscore.XXXXXX)
trap 'rm -rf "$T"' EXIT
away=0; to=0; neu=0
for n in "$@"; do
  pd=$(ls -d "$P/$M/$n"-* 2>/dev/null | head -1)
  qd=$(ls -d "$Q/$M/$n"-* 2>/dev/null | head -1)
  [ -z "$pd" ] || [ -z "$qd" ] && { echo "$n MISSING"; continue; }
  gold=$(grep -o 'golden cache hit [^)]*' "$pd/cmds.txt" | sed 's/golden cache hit //')
  g=$(find "$gold" \( -name golden.uhdm -o -name surelog.uhdm \) 2>/dev/null | head -1)
  [ -z "$g" ] && { echo "$n NO-GOLDEN"; continue; }
  norm() { sed -e "s#$2#WD#g" -e 's#/tmp/[^ ,)]*##g' | sort; }
  "$UD" "$g"              2>/dev/null | norm x "$gold" > "$T/g"
  "$UD" "$pd/slang.uhdm"  2>/dev/null | norm x "$pd"   > "$T/p"
  "$UD" "$qd/slang.uhdm"  2>/dev/null | norm x "$qd"   > "$T/q"
  dp=$(diff "$T/g" "$T/p" | grep -c '^[<>]'; true)
  dq=$(diff "$T/g" "$T/q" | grep -c '^[<>]'; true)
  if   [ "$dq" -lt "$dp" ]; then v=TO-GOLDEN; to=$((to+1))
  elif [ "$dq" -gt "$dp" ]; then v=AWAY-GOLDEN; away=$((away+1))
  else v=NEUTRAL; neu=$((neu+1)); fi
  echo "$n $M pristine=$dp patched=$dq $v"
done
echo "TOTALS TO-GOLDEN=$to AWAY-GOLDEN=$away NEUTRAL=$neu"
